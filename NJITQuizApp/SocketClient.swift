//
//  SocketClient.swift
//  NJITQuizApp
//
//  Created by MichaelSelsky on 9/22/15.
//  Copyright © 2015 self. All rights reserved.
//

import Foundation
import Socket_IO_Client_Swift
import SwiftyJSON

enum SocketMessage{
    case SubmitAttendance(blob: NSData)
}

typealias SocketEvent = () -> ()
typealias QuestionRecievedCallback = (MultipleChoiceQuestion) -> ()

class SocketClient {
    let userToken: String
    var socket: SocketIOClient = SocketIOClient(socketURL: "http://quiz-dev.herokuapp.com")
    var connectedEvent: SocketEvent?
    var questionCallback: QuestionRecievedCallback?
    
    init(userToken: String) {
        self.userToken = userToken
        let params: [String: AnyObject] = ["Authorization" : "\(self.userToken)"]
        let s = SocketIOClient(socketURL: "http://quiz-dev.herokuapp.com", opts: ["extraHeaders":params])
        s.nsp = "/classroom"
        s.on("connect") { (data, ack) in
            print("Connected")
            self.connectedEvent?()
        }
        s.on("news") { (data, ack) in
            
        }
        s.on("disconnect") { (data, ack) -> Void in
            print("Disconnected")
        }
        s.on("error") { (data, ack) -> Void in
            print("error")
        }
        s.on("assignQuestion") { (data, ack) -> Void in
            if let data = data {
                let question = self.parseQuestion(data)
                self.questionCallback?(question)
                let notification = UILocalNotification()
                notification.fireDate = NSDate()
                notification.alertTitle = question.prompt
                notification.alertAction = "Answer question"
                
                UIApplication.sharedApplication().scheduleLocalNotification(notification)
            }
        }
        self.socket = s
    }
    func start() {
        print("Starting Connection")
        self.socket.disconnect(fast: true)
        self.socket.connect(timeoutAfter: 10, withTimeoutHandler: nil);
    }
    
    func submitAttendance(blob: String) {
        dispatch_after(1, dispatch_get_main_queue()) { () -> Void in
            print("emitting: \(blob)")
            self.socket.emitWithAck("attendance", blob)(timeoutAfter: 0, callback: { (stuff) -> Void in
                print(stuff)
                let notification = NSNotification(name: "attendanceEvent", object: stuff)
                NSNotificationCenter.defaultCenter().postNotification(notification)
            })
        }
    }
    
    
    func parseQuestion(data: NSArray) -> MultipleChoiceQuestion {
        let json = JSON(data[0])
        let dueAt = json["dueAt"].stringValue
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let posix = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.locale = posix
        
        let dueDate = dateFormatter.dateFromString(dueAt)
        
        let rawQuestion = json["question"]
        let prompt = rawQuestion["prompt"].stringValue
        let assignmentID = json["_id"].stringValue
        let options = rawQuestion["options"]
        var answers = [MultipleChoiceAnswer]()
        for (_, option):(String, JSON) in options {
            let answerText = option["text"].stringValue
            let optionID = option["_id"].stringValue
            let ans = MultipleChoiceAnswer(text: answerText, answerID: optionID)
            answers.append(ans)
        }
        
        let question = MultipleChoiceQuestion(prompt: prompt, dueTime: dueDate ?? NSDate(timeIntervalSinceNow: 60), assignmentID:assignmentID, answers: answers)
        
        
        return question
        
    }
    
    func sendAnswer(answer: MultipleChoiceAnswer, question:MultipleChoiceQuestion) {
        let answerResponse: [String: String] = ["assignmentId": question.assignmentID, "optionId": answer.answerID]
        self.socket.emitWithAck("submitAnswer", answerResponse)(timeoutAfter: 5) { (data) in
            QL2Info(data)
        }
    }
    
    func disconnect() {
        self.socket.disconnect(fast: false)
    }
}
