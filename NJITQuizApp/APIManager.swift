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
    case Register((String, String))
    case GetCourses
    case GetCurrentCourses
    case GetGradesForSession(String)
}

extension API: MoyaTarget {
    public var baseURL: NSURL { return NSURL(string: productionURL)! }
    
    public var path: String {
        switch self {
        case .Register(_, _):
            return "/register"
        case .GetCourses, .GetCurrentCourses:
            return "/api/user/me/sessions"
        case .GetGradesForSession(let sessionID):
            return "api/user/me/session/\(sessionID)/grades"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .GetCourses, .GetCurrentCourses, .GetGradesForSession(_):
            return .GET
        default:
            return .POST
        }
    }
    
    public var parameters: [String: AnyObject]? {
        switch self {
        case .Register(let email, let password):
            return ["username": email, "password": password]
        case .GetCurrentCourses:
            return ["active": true]
        default:
            return nil
        }
    }
    
    public var parameterEncoding: Moya.ParameterEncoding {
        return .JSON
    }
    
    public var sampleData: NSData {
        return NSData() 
    }
}
