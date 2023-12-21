//
//  BarrierApp.swift
//  Barrier
//
//  Created by Jared Cassoutt on 10/24/23.
//

import SwiftUI
import FamilyControls
import ManagedSettings
import DeviceActivity

@main
struct BarrierApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject var model = MyModel.shared
    @StateObject var store = ManagedSettingsStore()
    
    var body: some Scene {
        WindowGroup {
            if let userDefaults = UserDefaults(suiteName: "group.com.haolo.barrier") {
                ContentView()
                    .environmentObject(model)
                    .environmentObject(store)
                    .defaultAppStorage(userDefaults)
            } else {
                Text("Failed to load:(")
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    var activityMonitor: DeviceActivityMonitorExtension?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        Task {
            do {
                try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            } catch {
                print("Failed to enroll user with error: \(error)")
            }
        }
        
        self.activityMonitor = DeviceActivityMonitorExtension()
        MySchedule.setSchedule()
        
        return true
    }
}

