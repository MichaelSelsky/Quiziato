//
//  ViewController.swift
//  NJITQuizApp
//
//  Created by MichaelSelsky on 9/15/15.
//  Copyright © 2015 self. All rights reserved.
//

import UIKit

let loginSegueIdentifier = "loginSegue"

class ViewController: UIViewController {
    
    var loggedInAccount: UserAccount?
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if let loggedInAccount = loggedInAccount{
            let alertController = UIAlertController(title: "Logged In", message: "Thanks for logging in \(loggedInAccount.account)", preferredStyle: .Alert)
            let dismissAction = UIAlertAction(title: "Dismiss", style: .Cancel, handler: { (action) -> Void in
                self.dismissViewControllerAnimated(true, completion: nil)
            })
            alertController.addAction(dismissAction )
            self.presentViewController(alertController, animated: true, completion: nil)
        } else {
            self.performSegueWithIdentifier(loginSegueIdentifier, sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == loginSegueIdentifier {
            let destination = segue.destinationViewController as! LoginViewController
            destination.loginCompletion = { (success: Bool, account: UserAccount?) in
                if success {
                    self.loggedInAccount = account
                    self.dismissViewControllerAnimated(true, completion: nil)
                } 
            }
        }
    }


}

