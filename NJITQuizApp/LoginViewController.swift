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

class LoginViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordLoginField: UITextField!
    
    let provider = MoyaProvider<API>()
    
    @IBAction func loginButtonPressed(sender: AnyObject) {
        let accountName = emailTextField.text!
        provider.request(API.Login((emailTextField.text!, passwordLoginField.text!))) { (data, statusCode, response, error) -> () in
            if let data = data {
                let json = JSON(data: data)
                let tokenInfo = json["access_token"]
                if let clientID = tokenInfo["clientID"].string,
                    userID = tokenInfo["userID"].string,
                    token = tokenInfo["token"].string {
                    let account = UserAccount(clientID: clientID, userID: userID, token: token, accountName: accountName)
                    do {
                        try account.createInSecureStore()
                        let newAccount = UserAccount.fetchAccount(accountName)
                        if let newAccount = newAccount {
                            if newAccount.clientID != account.clientID {
                                
                            }
                        } else {
                            
                        }
                    } catch {
                        print("error")
                    }
                    
                }
            }
        }
    }
    @IBAction func registerButtonPressed(sender: AnyObject) {
        provider.request(API.Register((emailTextField.text!, passwordLoginField.text!))) { (data, statusCode, response, error) -> () in
            print(statusCode, String(data: data!, encoding: NSUTF8StringEncoding))
        }
    }
    
}