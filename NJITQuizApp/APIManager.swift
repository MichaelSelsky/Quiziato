//
//  API.swift
//  NJITQuizApp
//
//  Created by MichaelSelsky on 9/15/15.
//  Copyright © 2015 self. All rights reserved.
//

import Foundation
import Moya

let clientID = "ios_1"
let clientSecret = "ios_1_secret"
let productionURL = "http://quiz-prod.herokuapp.com"
let devURL = "http://quiz-dev.herokuapp.com"

public enum API {
    case Login((String, String))
    case Register((String, String))
    case GetCourses
    case GetCurrentCourses
}

extension API: MoyaTarget {
    public var baseURL: NSURL { return NSURL(string: devURL)! }
    
    public var path: String {
        switch self {
        case .Login(_, _):
            return "/oauth/token"
        case .Register(_, _):
            return "/register"
        case .GetCourses:
            return "/me/sessions"
        case .GetCurrentCourses:
            return "/me/sessions?active=true"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .GetCourses:
            return .GET
        case .GetCurrentCourses:
            return .GET
        default:
            return .POST
        }
    }
    
    public var parameters: [String: AnyObject]? {
        switch self {
        case .Login(let email, let password):
            return ["username": email, "password": password, "client_id":clientID, "client_secret":clientSecret, "grant_type":"password"]
        case .Register(let email, let password):
            return ["username": email, "password": password]
        default:
            return nil
        }
    }
    
    
    public var parameterEncoding: Moya.ParameterEncoding {
        switch self {
        case .Login(_, _):
            return .URL
        default:
            return .JSON
        }
    }
    
    public var sampleData: NSData {
        return NSData() 
    }
}
