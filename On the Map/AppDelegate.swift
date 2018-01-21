//
//  AppDelegate.swift
//  On the Map
//
//  Created by Ben Juhn on 7/11/17.
//  Copyright © 2017 Ben Juhn. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let udacityBlue = UIColor(red: 2/255.0, green: 179/255.0, blue: 228/255.0, alpha: 1)

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        window!.rootViewController = LoginViewController()
        window!.makeKeyAndVisible()
        
        UINavigationBar.appearance().tintColor = udacityBlue
        UITabBar.appearance().tintColor = udacityBlue
        
        return true
    }

}

