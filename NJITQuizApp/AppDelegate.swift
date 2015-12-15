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
        
        QorumLogs.enabled = true
        QL2Info("Application Launching")
        
        self.window?.tintColor = UIColor(red: 0.204, green: 0.596, blue: 0.859, alpha: 1.0)
        
        TemplateBackgroundView.appearance().backgroundColor = UIColor(red: 0.925, green: 0.941, blue: 0.945, alpha: 1.0)
        
        return true
    }
}

func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}
