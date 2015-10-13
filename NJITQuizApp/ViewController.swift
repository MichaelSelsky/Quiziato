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
        
//        let gradientLayer = CAGradientLayer()
//        gradientLayer.frame = self.view.frame
//        gradientLayer.colors = [UIColor(red: 255.0/255.0, green: 227.0/255.0, blue: 55/255.0, alpha: 1.0), UIColor(red: 255.0/255.0, green: 237.0/255.0, blue: 131.0/255.0, alpha: 1.0)];
//        self.view.layer.addSublayer(gradientLayer)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if let loggedInAccount = loggedInAccount{
            NSUserDefaults.standardUserDefaults().setObject(loggedInAccount.account, forKey: "loggedInID")
            self.socketClient = SocketClient(userToken: loggedInAccount.token)
        } else {
            self.performSegueWithIdentifier(loginSegueIdentifier, sender: self)
        }
    }
    
    @IBAction func connectToSocketButtonPressed(sender: AnyObject) {
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
}

