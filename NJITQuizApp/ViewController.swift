//
//  ViewController.swift
//  NJITQuizApp
//
//  Created by MichaelSelsky on 9/15/15.
//  Copyright © 2015 self. All rights reserved.
//

import UIKit
import Moya
import Argo
import Heimdallr

let loginSegueIdentifier = "loginSegue"
let rejoinClassSegueIdentifier = "RejoinClassSegue"

class ViewController: UIViewController {
    
    var socketClient: SocketClient!
    var hasCheckedLogin: Bool = false
    
    var oAuthToken: OAuthAccessToken? = nil
    
    var provider: MoyaProvider<API>!
    
    let credentials = OAuthClientCredentials(id: clientID, secret: clientSecret)
    let tokenURL = NSURL(string: "http://quiz-dev.herokuapp.com/oauth/token")!
    
    var heimdallr: Heimdallr!
    
    
    
    @IBOutlet weak var roomTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        heimdallr = Heimdallr(tokenURL: tokenURL, credentials: credentials)
        
        let requestClosure = { (endpoint: Endpoint<API>, done: NSURLRequest -> Void) in
            let request = endpoint.urlRequest // This is the request Moya generates
            
            self.heimdallr.authenticateRequest(request, completion: { (result) -> () in
                switch result {
                case .Success(let authenticatedRequest):
                    done(authenticatedRequest)
                default:
                    done(request)
                }
            })
        }
        
        provider = MoyaProvider(requestClosure: requestClosure)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if !heimdallr.hasAccessToken  {
            self.performSegueWithIdentifier(loginSegueIdentifier, sender: self)
        } else {
            let accessToken = heimdallr.accessToken?.accessToken ?? ""
            self.socketClient = SocketClient(userToken: accessToken)
        }
    }
    
    @IBAction func rejoinClassButtonTapped(sender: AnyObject) {
        joinOnGoingSession()
    }
    
    func joinOnGoingSession() {
        self.provider.request(.GetCourses, completion: { (data, statusCode, response, error) -> () in
            QL1Debug(data)
            if statusCode == 200 {
                var json: AnyObject?
                do {
                    json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableLeaves)
                } catch {
                    QL4Error(error)
                }
                guard let j = json else {
                    return
                }
                let sessions: [Session]? = decode(j)
                if let sessions = sessions {
                    let currentSessions = sessions.filter({ (session) -> Bool in
                        return !session.ended
                    })
                    if let currentSession = currentSessions.first {
                        self.socketClient.connectedEvent = {
                            self.socketClient.submitAttendance(currentSession.roomId)
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.performSegueWithIdentifier(rejoinClassSegueIdentifier, sender: self)
                            })
                        }
                        self.socketClient.start()
                    }
                }
            }
        })
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
            destination.socket = self.socketClient
        }
        
        if segue.identifier == rejoinClassSegueIdentifier {
            let navVc = segue.destinationViewController as! UINavigationController
            let classVC = navVc.viewControllers[0] as! ClassroomQuizTableViewController
            classVC.socketConnection = self.socketClient
        }
    }
}

