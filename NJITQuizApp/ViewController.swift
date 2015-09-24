//
//  ViewController.swift
//  NJITQuizApp
//
//  Created by MichaelSelsky on 9/15/15.
//  Copyright © 2015 self. All rights reserved.
//

import UIKit

let loginSegueIdentifier = "loginSegue"
let socketConnection = SocketClient()

class ViewController: UIViewController {
    
    var loggedInAccount: UserAccount?
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
//        if let loggedInAccount = loggedInAccount{
//            let alertController = UIAlertController(title: "Logged In", message: "Thanks for logging in \(account!.account)", preferredStyle: .Alert)
//            let dismissAction = UIAlertAction(title: "Dismiss", style: .Cancel, handler: { (action) -> Void in
//                self.dismissViewControllerAnimated(true, completion: nil)
//            })
//            alertController.addAction(dismissAction )
//            self.presentViewController(alertController, animated: true, completion: nil)
//            connectToSocket()
//            
//        } else {
//            self.performSegueWithIdentifier(loginSegueIdentifier, sender: self)
//        }
    }
    
    @IBAction func connectToSocketButtonPressed(sender: AnyObject) {
        self.connectToSocket()
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == loginSegueIdentifier {
            let destination = segue.destinationViewController as! LoginViewController
            destination.loginCompletion = { (success: Bool, account: UserAccount?) in
                if success {
                    self.loggedInAccount = account
                    self.dismissViewControllerAnimated(true, completion: nil)
                    let alertController = UIAlertController(title: "Logged In", message: "Thanks for logging in \(account!.account)", preferredStyle: .Alert)
                    let dismissAction = UIAlertAction(title: "Dismiss", style: .Cancel, handler: { (action) -> Void in
                        self.dismissViewControllerAnimated(true, completion: nil)
                    })
                    alertController.addAction(dismissAction )
                    self.presentViewController(alertController, animated: true, completion: nil)

                } 
            }
        }
    }

    func connectToSocket() {
        socketConnection.start()
    }
}

