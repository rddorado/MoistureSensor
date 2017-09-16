//
//  AppDelegate.swift
//  msensor
//
//  Created by Ronaldo II Dorado on 15/9/17.
//  Copyright © 2017 Ronaldo II Dorado. All rights reserved.
//
import UIKit
import Firebase

@UIApplicationMain

// MARK:- AppDelegate Life Cycle Methods
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = ViewController()
        window?.makeKeyAndVisible()
        
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        Auth.signOut()
    }
}


