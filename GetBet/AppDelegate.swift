//
//  AppDelegate.swift
//  GetBet
//
//  Created by Aasrith Mareddy on 15/10/23.
//

import SwiftUI
import Firebase
import GoogleSignIn

@main
struct GetBet: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State private var showSignInView: Bool = false
    
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        return true
    }
}

func application(_ app: UIApplication,
                 open url: URL,
                 options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
  return GIDSignIn.sharedInstance.handle(url)
}
