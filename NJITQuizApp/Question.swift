//
//  Question.swift
//  NJITQuizApp
//
//  Created by MichaelSelsky on 10/15/15.
//  Copyright © 2015 self. All rights reserved.
//

import Foundation

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

struct MultipleChoiceAnswer {
    let text: String
    let answerID: String
}
