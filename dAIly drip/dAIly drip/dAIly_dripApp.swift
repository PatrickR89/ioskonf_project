//
//  dAIly_dripApp.swift
//  dAIly drip
//
//  Created by Patrick Ružman on 04.05.2026..
//

import FirebaseCore
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions options: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        BackendLogger.info("Configuring Firebase")
        FirebaseApp.configure()
        BackendLogger.info(
            "Firebase configured",
            metadata: [
                "firebaseAppName": FirebaseApp.app()?.name,
                "projectID": FirebaseApp.app()?.options.projectID,
                "googleAppID": FirebaseApp.app()?.options.googleAppID,
                "apiKeySuffix": FirebaseApp.app()?.options.apiKey.map { String($0.suffix(6)) },
            ]
        )
        
        return true
    }
}



@main
struct dAIly_dripApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var closetRepository = ClosetRepository()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(closetRepository)
        }
    }
}
