//
//  AppDelegate.swift
//  NJITQuizApp
//
//  Created by MichaelSelsky on 9/15/15.
//  Copyright © 2015 self. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        QorumLogs.enabled = true
        QL2Info("Application Launching")
        
        self.window?.tintColor = UIColor(red: 0.204, green: 0.596, blue: 0.859, alpha: 1.0)
        
        TemplateBackgroundView.appearance().backgroundColor = UIColor(red: 0.925, green: 0.941, blue: 0.945, alpha: 1.0)
        
        return true
    }
}

