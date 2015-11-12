//
//  ViewController.swift
//  NJITQuizApp
//
//  Created by MichaelSelsky on 9/15/15.
//  Copyright © 2015 self. All rights reserved.
//

import UIKit
import Moya
import Heimdallr

let loginSegueIdentifier = "loginSegue"

class ViewController: UIViewController {
    
    var socketClient: SocketClient!
    var hasCheckedLogin: Bool = false
    
    var oAuthToken: OAuthAccessToken? = nil
    
    var provider: MoyaProvider<API>!
    
    let credentials = OAuthClientCredentials(id: clientID, secret: clientSecret)
    let tokenURL = NSURL(string: "http://quiz-dev.herokuapp.com/oauth/token")!
    
    var heimdallr: Heimdallr!
    
    let requestClosure = { (endpoint: Endpoint<API>, done: NSURLRequest -> Void) in
        var request = endpoint.urlRequest // This is the request Moya generates
    }
    
    @IBOutlet weak var roomTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        provider = MoyaProvider(requestClosure: requestClosure)
        heimdallr = Heimdallr(tokenURL: tokenURL, credentials: credentials)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if !heimdallr.hasAccessToken  {
            self.performSegueWithIdentifier(loginSegueIdentifier, sender: self)
        }
    }
    
    @IBAction func connectToSocketButtonPressed(sender: AnyObject) {
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == loginSegueIdentifier {
            let destination = segue.destinationViewController as! LoginViewController
            destination.heimdallr = self.heimdallr
            destination.loginCompletion = { (success: Bool) in
                if success {
                    self.dismissViewControllerAnimated(true, completion: nil)
                    let alertController = UIAlertController(title: "Logged In", message: "Thanks for logging in", preferredStyle: .Alert)
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
            let accessToken = heimdallr.accessToken?.accessToken ?? ""
            self.socketClient = SocketClient(userToken: accessToken)
            destination.socket = self.socketClient
        }
    }
}

