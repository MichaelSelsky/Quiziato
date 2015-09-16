//
//  User.swift
//  NJITQuizApp
//
//  Created by MichaelSelsky on 9/15/15.
//  Copyright © 2015 self. All rights reserved.
//

import Foundation
import Locksmith

let serviceName = "Quizzer"
let UserAccountClientIDKey = "clientID", UserAccountUserIDKey = "userID", UserAccountTokenKey = "token"


struct UserAccount: GenericPasswordSecureStorable, CreateableSecureStorable, ReadableSecureStorable, DeleteableSecureStorable {
    let clientID: String
    let userID: String
    let token: String
    
    let service = serviceName
    var account: String
    
    var data: [String: AnyObject] {
        return [UserAccountClientIDKey: clientID, UserAccountUserIDKey: userID, UserAccountTokenKey: token]
    }
    
    init(clientID:String, userID:String, token:String, accountName: String) {
        self.clientID = clientID
        self.userID = userID
        self.token = token
        self.account = accountName
    }
    
    static func fetchAccount(account: String) -> UserAccount? {
        struct ReadableUserAccount: GenericPasswordSecureStorable, ReadableSecureStorable {
            let service = serviceName
            var account: String
            
            init(accountName:String){
                account = accountName
            }
        }
        
        let readableAccount = ReadableUserAccount(accountName: account)
        let accountData = readableAccount.readFromSecureStore()
        if let accountData = accountData{
            if let data = accountData.data, clientID = data[UserAccountClientIDKey] as? String, userID = data[UserAccountUserIDKey] as? String, token = data[UserAccountTokenKey] as? String {
                return UserAccount(clientID: clientID, userID: userID, token: token, accountName: account)
            }
        }
        
        return nil
    }
}