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

typealias GradedSession = (Session, Double, [Assignment]?)

class Wrapper<T>{
    let wrappedValue: T
    init(value: T) {
        wrappedValue = value
    }
}


struct Assignment {
    let question: MultipleChoiceQuestion
    let graded: Bool
    let correct: Bool
    let correctAns: String?
    let submittedAns: String?
}

extension Assignment: Decodable {
    static func decode(json: JSON) -> Decoded<Assignment.DecodedType> {
        QL1Debug(json)
        return curry(Assignment.init) <^> json <| "assignment" <*> json <| "graded" <*> json <| "correct" <*> json <|? ["assignment", "question", "correctAnswer"] <*> json <|? "submission"
    }
}

struct Course {
    let name: String
    let instructor: Instructor
    let id: String
}

extension Course: Decodable {
    static func decode(json: JSON) -> Decoded<Course.DecodedType> {
        return curry(Course.init) <^> json <| ["course", "full"] <*> json <| "instructor" <*> json <| ["course", "full"]
    }
}

struct Instructor {
    let name: String
}

extension Instructor: Decodable {
    static func decode(json: JSON) -> Decoded<Instructor.DecodedType> {
        return curry(Instructor.init) <^> json <| ["name", "full"]
    }
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

struct MultipleChoiceAnswer {
    let text: String
    let answerID: String
}

extension MultipleChoiceAnswer: Decodable {
    internal static func decode(json: JSON) -> Decoded<MultipleChoiceAnswer.DecodedType> {
        return curry(MultipleChoiceAnswer.init) <^> json <| "text" <*> json <| "_id"
    }
}

struct Session {
    let roomId: String
    let ended: Bool
    let date: NSDate
    let id: String
    var course: Course
//    let assignments
}

extension Session: Decodable {
    static func decode(json: JSON) -> Decoded<Session.DecodedType> {
        QL1Debug(json)
        return curry(Session.init) <^> json <| ["session", "roomId"] <*> json <| ["session", "ended"] <*> json <| ["session", "date"] <*> json <| ["session", "_id"] <*> json <| "session"
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
