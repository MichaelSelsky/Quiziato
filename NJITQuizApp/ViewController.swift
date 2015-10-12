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
    var socketClient: SocketClient!
    
    @IBOutlet weak var roomTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        let loggedInAccountID = NSUserDefaults.standardUserDefaults().objectForKey("loggedInID") as? String
        if let loggedInAccountID = loggedInAccountID where loggedInAccountID.characters.count > 0 {
            self.loggedInAccount = UserAccount.fetchAccount(loggedInAccountID)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if let loggedInAccount = loggedInAccount{
            let alertController = UIAlertController(title: "Logged In", message: "Thanks for logging in \(loggedInAccount.account)", preferredStyle: .Alert)
            NSUserDefaults.standardUserDefaults().setObject(loggedInAccount.account, forKey: "loggedInID")
            let dismissAction = UIAlertAction(title: "Dismiss", style: .Cancel, handler: { (action) -> Void in
                self.dismissViewControllerAnimated(true, completion: nil)
            })
            alertController.addAction(dismissAction )
            self.presentViewController(alertController, animated: true, completion: nil)
            self.socketClient = SocketClient(userToken: loggedInAccount.token)
        } else {
            self.performSegueWithIdentifier(loginSegueIdentifier, sender: self)
        }
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
        
        if segue.identifier == "QRSegue" {
            let destination = segue.destinationViewController as! QRScanningViewController
            destination.socket = self.socketClient
        }
    }

    func connectToSocket() {
//        self.socketClient.connectedEvent = {
//            self.socketClient.submitAttendance(self.roomTextField.text ?? "")
//        }
//        self.socketClient.start()
    }
}

