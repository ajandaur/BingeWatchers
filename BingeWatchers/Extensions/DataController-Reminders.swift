//
//  DataController-Reminders.swift
//  BingeWatchers
//
//  Created by Anmol  Jandaur on 6/7/22.
//

import UserNotifications

extension DataController {
    // MARK: - Local Notifications
    

    
    
    //  method that will be called from EditProjectView to add a reminder for a project
    func addReminders(for project: Project, completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        
        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                self.requestNotifications { success in
                    if success {
                        self.placeReminders(for: project, completion: completion)
                    } else {
                        DispatchQueue.main.async {
                            completion(false)
                        }
                    }
                }
            case . authorized:
                self.placeReminders(for: project, completion: completion)
            default:
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }
    

    // method that will be called from EditProjectView to remove a reminder for a project
    func removeReminders(for project: Project) {
        //  every managed object has an objectID property that can be converted into a URL designed specifically for archiving
        let center = UNUserNotificationCenter.current()
        let id = project.objectID.uriRepresentation().absoluteString
        center.removePendingNotificationRequests(withIdentifiers: [id])
    }
    
    // This method is going to request notification authorization from iOS, asking to be able to show an alert and play a sound, then call its completion handler with whatever the system replies back with – in this case, whether the authorization was granted or not.
    private func requestNotifications(completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            completion(granted)
        }
    }
    
    // second private method that does the work of placing a single notification for a project
    private func placeReminders(for project: Project, completion: @escaping (Bool) -> Void) {
        //  UNMutableNotificationContent, where we describe how the notification should look to the system – what title it has, whether a picture is attached, whether it should be grouped with other similar notifications, and more
        let content = UNMutableNotificationContent()
        content.sound = .default
        content.title = project.projectTitle
        
        if let projectDetail = project.detail {
            content.subtitle = projectDetail
        }
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: project.reminderTime ?? Date())
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        // wrap up the content and trigger in a single notification, giving it a unique ID
        let id = project.objectID.uriRepresentation().absoluteString
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            DispatchQueue.main.async {
                if error == nil {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }
}
