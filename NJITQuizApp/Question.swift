//
//  Question.swift
//  NJITQuizApp
//
//  Created by MichaelSelsky on 10/15/15.
//  Copyright © 2015 self. All rights reserved.
//

import Foundation

struct MultipleChoiceQuestion {
    let prompt: String
    let dueTime: NSDate
    let answers: [MultipleChoiceAnswer]
    init(prompt: String, dueTime: NSDate, answers: [MultipleChoiceAnswer]) {
        self.prompt = prompt
        self.dueTime = dueTime
        self.answers = answers
    }
}

struct MultipleChoiceAnswer {
    let text: String
    let answerID: String
    init(text: String, answerID:String) {
        self.text = text
        self.answerID = answerID
    }
}
