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

class LoginViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordLoginField: UITextField!
    
    let provider = MoyaProvider<API>()
    
    override func viewDidLoad() {
        let account = UserAccount.fetchAccount("mps36+0@njit.edu")
        print(account)
    }
    
    @IBAction func loginButtonPressed(sender: AnyObject) {
        let accountName = emailTextField.text!
        provider.request(.Login((emailTextField.text!, passwordLoginField.text!))) { (data, statusCode, response, connectionError) -> () in
            if let data = data {
                let json = JSON(data: data)
                let tokenInfo = json["access_token"]
                if let clientID = tokenInfo["clientID"].string,
                    userID = tokenInfo["userID"].string,
                    token = tokenInfo["token"].string {
                        let account = UserAccount(clientID: clientID, userID: userID, token: token, accountName: accountName)
                        do {
                            try account.deleteFromSecureStore()
                            try account.createInSecureStore()
                        } catch LocksmithError.Duplicate {
                            print("Duplicate")
                        } catch {
                            
                        }
                        
                }
            }
        }
    }
    @IBAction func registerButtonPressed(sender: AnyObject) {
        provider.request(.Register((emailTextField.text!, passwordLoginField.text!))) { (data, statusCode, response, error) -> () in
            print(statusCode, String(data: data!, encoding: NSUTF8StringEncoding))
        }
    }
    
}