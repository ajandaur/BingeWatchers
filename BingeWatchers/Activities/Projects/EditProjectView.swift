//
//  EditProjectView.swift
//  BingeWatchers
//
//  Created by Anmol  Jandaur on 1/13/22.
//

import SwiftUI
import CoreHaptics

struct EditProjectView: View {
    @ObservedObject var project: Project
    
    @EnvironmentObject var dataController: DataController
    @Environment(\.presentationMode) var presentationMode
    
    @State private var engine = try? CHHapticEngine()
    
    @State private var title: String
    @State private var detail: String
    @State private var color: String
    @State private var showingDeleteConfirm = false
    
    
    // MARK: - Local Notifications
    // whether the time picker is showing
    @State private var remindMe: Bool
    // track user's currently selected time
    @State private var reminderTime: Date
    // track whether alert is showing or not
    @State private var showingNotificationsError = false
    
    let colorColumns = [
        GridItem(.adaptive(minimum: 44))
    ]
    
    // copy values from CoreData object into @State variables
    init(project: Project) {
        self.project = project
        
        _title = State(wrappedValue: project.projectTitle)
        _detail = State(wrappedValue: project.projectDetail)
        _color = State(wrappedValue: project.projectColor)
        
        if let projectReminderTime = project.reminderTime {
            _reminderTime = State(wrappedValue: projectReminderTime)
            _remindMe = State(wrappedValue: true)
        } else {
            _reminderTime = State(wrappedValue: Date())
            _remindMe = State(wrappedValue: false)
        }
    }
    
    var body: some View {
        Form {
            Section(header: Text("Basic settings")) {
                TextField("Project name", text: $title.onChange(update))
                TextField("Description of this project", text: $detail.onChange(update))
            }
            
            Section(header: Text("Custom project color")) {
                LazyVGrid(columns: colorColumns) {
                    // Make each color as a rounded square on the screen
                    ForEach(Project.colors, id: \.self, content: colorButton)
                }
                .padding(.vertical)
            }
            
            Section(footer: Text("Closing a project moves it from the Open to the Closed tab; deleting it will remove the project.")) {
                Button(project.closed ? "Reopen this project" : "Close this project", action: toggleClosed) 
                
                Button("Delete this project") {
                    showingDeleteConfirm.toggle()
                }
                .accentColor(.red)
                
            }
            
            Section(header: Text("Project reminders")) {
                Toggle("Show reminders", isOn: $remindMe.animation().onChange(update))
                    .alert(isPresented: $showingNotificationsError) {
                        Alert(
                            title: Text("Oops!"),
                            message: Text("There was a problem. Please check you have notifications enabled."),
                            primaryButton: .default(Text("Check Settings"), action: showAppSettings),
                            secondaryButton: .cancel()
                        )
                    }
                
                if remindMe {
                    DatePicker("Reminder time", selection: $reminderTime.onChange(update), displayedComponents: .hourAndMinute)
                }
            }
            
        }
        .navigationTitle("Edit Project")
        .onDisappear(perform: dataController.save)
        .alert(
            isPresented: $showingDeleteConfirm) {
                Alert(
                    title: Text("Delete project?"),
                    message: Text("Are you sure you want to delete this project? You will also delete all the items it contains."), // swiftlint:disable:line_length
                    primaryButton: .default(Text("Delete"), action: delete),
                    secondaryButton: .cancel())
            }
    }
    
    func showAppSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl)
        }
    }
    
    // update() method that copies values from our @State properties over to the original Core Data object
    func update() {
        project.title = title
        project.detail = detail
        project.color = color
        
        // we’re going to ask the data controller to add reminders for a project, but if it fails then we need to clear the reminder time, set remindMe back to false, and show the user an error
        if remindMe {
            project.reminderTime = reminderTime
            
            dataController.addReminders(for: project) { success in
                if success == false {
                    project.reminderTime = nil
                    remindMe = false
                    
                    showingNotificationsError = true
                }
            }
        } else {
            project.reminderTime = nil
            dataController.removeReminders(for: project)
        }
    }
    
    func delete() {
        dataController.delete(project)
        presentationMode.wrappedValue.dismiss()
    }
    
    func toggleClosed() {
        project.closed.toggle()
        
        if project.closed {
            do {
                try engine?.start()
                
                //  Core Haptics gives us two parameters here: sharpness, to determine whether the effect is pronounced or dull, and intensity to determine the relative strength of the vibration
                let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0)
                let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
                
                //  Parameter curves are created using control points, each of which set a value over time. If we set a value of 1 at the start, and a value of 0 at the end, Core Haptics will create a smooth curve for us.
                
                // We don’t actually say what the 1 and 0 values mean when creating the control points, and neither do we have a specific time in mind for “start” and “end” – these are provided as relative times, so if we say the relative time is 1 it means the end of the haptic no matter how long the actual effect is.
                
                let start = CHHapticParameterCurve.ControlPoint(relativeTime: 0, value: 1)
                let end = CHHapticParameterCurve.ControlPoint(relativeTime: 1, value: 0)
                
                // use that curve to control the haptic strength
                let parameter = CHHapticParameterCurve(
                    parameterID: .hapticIntensityControl,
                    controlPoints: [start, end],
                    relativeTime: 0
                )
                
                // transient (a quick tap), strong and dull
                let event1 = CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [intensity, sharpness],
                    relativeTime: 0
                )
                
                // continuous (a longer buzz), strong and dull, lasting for one second, but starting after 1/8th of a second so that it feels separate from the quick tap we just made
                let event2 = CHHapticEvent(
                    eventType: .hapticContinuous,
                    parameters: [intensity, sharpness],
                    relativeTime: 0.125,
                    duration: 1
                )
                
                let pattern = try CHHapticPattern(events: [event1, event2], parameterCurves: [parameter])
                
                let player = try engine?.makePlayer(with: pattern)
                try player?.start(atTime: 0)
                
            } catch {
                // haptics did not work, just fail quietly..
            }
            
        }
    }
    
    func colorButton(for item: String) -> some View {
        ZStack {
            Color(item)
                .aspectRatio(1, contentMode: .fit)
                .cornerRadius(6)
            
            if item == color {
                Image(systemName: "checkmark.circle")
                    .foregroundColor(.white)
                    .font(.largeTitle)
            }
        }
        .onTapGesture {
            color = item
            update()
        }
        .accessibilityElement(children: .ignore)
        .accessibilityAddTraits(
            item == color
            ? [.isButton, .isSelected]
            : .isButton
        )
        .accessibilityLabel(LocalizedStringKey(item))
    }
    
}

struct EditProjectView_Previews: PreviewProvider {
    static var previews: some View {
        EditProjectView(project: Project.example)
    }
}
