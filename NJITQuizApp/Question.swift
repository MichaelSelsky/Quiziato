//
//  Question.swift
//  NJITQuizApp
//
//  Created by MichaelSelsky on 10/15/15.
//  Copyright © 2015 self. All rights reserved.
//

import Foundation
import Argo
import Curry

struct Course {
    let name: String
    let instructor: Instructor
}

struct Instructor {
    let name: String
}

struct MultipleChoiceQuestion {
    let prompt: String
    let dueTime: NSDate
    let assignmentID: String
    let answers: [MultipleChoiceAnswer]
}

extension MultipleChoiceQuestion: Decodable {
    internal static func decode(json: JSON) -> Decoded<MultipleChoiceQuestion.DecodedType> {
        return curry(MultipleChoiceQuestion.init) <^> json <| ["question", "prompt"] <*> json <| "dueAt" <*> json <| "_id" <*> json <|| ["question", "options"]
    }
}

extension NSDate: Decodable {
    public static func decode(json: JSON) -> Decoded<NSDate.DecodedType> {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let posix = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.locale = posix
        
        switch json {
        case let .String(s):
            if let date = dateFormatter.dateFromString(s) {
                return pure(date)
            } else {
                return Decoded.Failure(.TypeMismatch(expected: "Should be a string", actual: "\(json) is not a date"))
            }
        default: return Decoded.Failure(.TypeMismatch(expected: "Should be a string", actual: "\(json) is not a date"))
        }
    }
}

struct MultipleChoiceAnswer {
    let text: String
    let answerID: String
}

extension MultipleChoiceAnswer: Decodable {
    internal static func decode(json: JSON) -> Decoded<MultipleChoiceAnswer.DecodedType> {
        return curry(MultipleChoiceAnswer.init) <^> json <| "text" <*> json <| "_id"
    }
}
