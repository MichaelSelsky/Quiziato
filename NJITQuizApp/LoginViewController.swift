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

// TODO: clean up ViewController 
class LoginViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordLoginField: UITextField!
    
    let provider = MoyaProvider<API>()
    var loginCompletion: (Bool, UserAccount?) -> () = { (success, _) in
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
        let username = emailTextField.text!
        let password = passwordLoginField.text!
//        registerWithUsername(username, password: password)
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
    
    func loginWithUsername(username: String, password: String, completion:(Bool, UserAccount?) -> ()){
        provider.request(.Login((username, password))) { (data, statusCode, response, connectionError) -> () in
            var success = true
            var returnAccount: UserAccount?
            if statusCode != 200 {
                success = false //TODO: make this success thing a lot simpler
                self.showError()
            }
            if let data = data {
                let json = JSON(data: data) // I should move this to some class. Maybe make a nice initializer on UserAccount
                let tokenInfo = json["access_token"]
                if let clientID = tokenInfo["clientID"].string,
                    userID = tokenInfo["userID"].string,
                    token = tokenInfo["token"].string {
                        let account = UserAccount(clientID: clientID, userID: userID, token: token, accountName: username)
                        do { // TODO: make this nicer to work with
                            try account.createInSecureStore()
                            returnAccount = account
                            completion(success, returnAccount)
                        } catch LocksmithError.Duplicate {
                            print("Duplicate")
                            success = true
                            returnAccount = account
                            completion(success, returnAccount)
                        } catch let error {
                            print("Login Error\(error)")
                            success = false
                            self.showError()
                            completion(success, returnAccount)
                        }
                } else {
                    success = false
                    completion(success, returnAccount)
                }
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