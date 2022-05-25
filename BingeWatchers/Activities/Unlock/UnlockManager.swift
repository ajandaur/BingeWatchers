//
//  UnlockManager.swift
//  BingeWatchers
//
//  Created by Anmol  Jandaur on 5/23/22.
//

import Foundation
import Combine
import StoreKit

class UnlockManager: NSObject, ObservableObject, SKPaymentTransactionObserver, SKProductsRequestDelegate {
 
    
    enum RequestState {
        case loading // started the request but don't have a response
        case loaded(SKProduct) // have a successful response from Apple describing what products are avaliable for purchase
        case failed(Error?) // something went wrong with our request for products or with our attempt to make a purchase
        case purchased // user successfully purchased the iAP
        case deferred // current user can't make the purchase themselves, neds an external action
    }
    
    private enum StoreError: Error {
        case invalidIdentifiers, missingProduct
    }
    
    @Published var requestState = RequestState.loading
    private let dataController: DataController
    let request: SKProductsRequest
    var loadedProducts = [SKProduct]()
    
    // property will return false if the user has a device with App Store purchasing disabled
    var canMakePayments: Bool {
        SKPaymentQueue.canMakePayments()
    }
    
    init(dataController: DataController) {
        // Store the data controller we were sent.
        self.dataController = dataController
        
        // Prepare to look for our unlock product.
        let productIDs = Set(["jandaur.anmol.BingeWatchers.unlock"])
        request = SKProductsRequest(productIdentifiers: productIDs)
        
        // This is required because we inherit from NSObject.
        super.init()
        
        // start watching the payment queue.
        SKPaymentQueue.default().add(self)
        
        // avoid starting the product request if our unlock has already happened
        guard dataController.fullVersionUnlocked == false else { return }
        
        // Set ourselves up to be notified when the product request completes.
        request.delegate = self
        
        // start the request
        request.start()
    }
    
    deinit {
        SKPaymentQueue.default().remove(self)
    }
    
    func buy(product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    func restore() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        DispatchQueue.main.async { [self] in
            for transaction in transactions {
                switch transaction.transactionState {
                case .purchased, .restored:
                    self.dataController.fullVersionUnlocked = true
                    self.requestState = .purchased
                    queue.finishTransaction(transaction)
                    
                case .failed:
                    if let product = loadedProducts.first {
                        self.requestState = .loaded(product)
                    } else {
                        self.requestState = .failed(transaction.error)
                    }
                    
                    queue.finishTransaction(transaction)
                    
                case .deferred:
                    self.requestState = .deferred
                    
                default:
                    break
                }
            }
        }
    }
    
    // stashes away the list of products that were sent back, then pulls out the first product that was returned, or flags up an error if none could be found. It will then check there were no invalid identifiers, but if there were we’ll flag up a different error. Finally, if we have a product and no invalid identifiers, we’ll consider our store to be loaded.
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            // Store the returned products for alter, if we need them.
            self.loadedProducts = response.products
            
            guard let unlock = self.loadedProducts.first else {
                self.requestState  = .failed(StoreError.missingProduct)
                return
            }
            
            if response.invalidProductIdentifiers.isEmpty == false {
                print("ALERT: Recieved invalid product identifiers: \(response.invalidProductIdentifiers)")
                self.requestState = .failed(StoreError.invalidIdentifiers)
                return
            }
            
            self.requestState = .loaded(unlock)
        }
    }
}
