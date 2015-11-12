//
//  LoginViewController.swift
//  NJITQuizApp
//
//  Created by MichaelSelsky on 9/15/15.
//  Copyright © 2015 self. All rights reserved.
//

import UIKit
import Moya
import SwiftyJSON
import Locksmith
import Heimdallr

// TODO: clean up ViewController 
class LoginViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordLoginField: UITextField!
    
    var heimdallr: Heimdallr!
    
    let provider = MoyaProvider<API>()
    var loginCompletion: (Bool) -> () = { (success) in
        if success {
            
        }
    }
    
    override func viewDidLoad() {
        
    }
    
    @IBAction func loginButtonPressed(sender: AnyObject) {
        let username = emailTextField.text!
        let password = passwordLoginField.text!
        loginWithUsername(username, password: password, completion: loginCompletion)
    }
    @IBAction func registerButtonPressed(sender: AnyObject) {
        
    }
    
    func registerWithUsername(username:String, password: String) {
        provider.request(.Register((username, password))) { (data, statusCode, response, error) -> () in
            print(statusCode, String(data: data!, encoding: NSUTF8StringEncoding))
            if statusCode == 200 {
                self.loginWithUsername(username, password: password, completion: self.loginCompletion)
            } else {
                self.showError()
            }
        }
    }
    
    func loginWithUsername(username: String, password: String, completion:(Bool) -> ()){
        heimdallr.requestAccessToken(username: username, password: password) { (result) in
            switch result {
            case .Success:
                completion(true)
            case .Failure(let error):
                print(error)
            }
        }
    }
    
    func showError(){
        let alertController = UIAlertController(title: "Login Failed", message: "Something went wrong", preferredStyle: .Alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil)
        alertController.addAction(dismissAction )
        self.presentViewController(alertController, animated: true, completion: nil) //TODO: Make this a lot nicer
    }
    
}