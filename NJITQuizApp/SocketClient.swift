//
//  SocketClient.swift
//  NJITQuizApp
//
//  Created by MichaelSelsky on 9/22/15.
//  Copyright © 2015 self. All rights reserved.
//

import Foundation
import Socket_IO_Client_Swift
import Argo

enum SocketMessage{
    case SubmitAttendance(blob: NSData)
}

typealias SocketEvent = () -> ()
typealias QuestionRecievedCallback = (MultipleChoiceQuestion?) -> ()

class SocketClient {
    let userToken: String
    var socket: SocketIOClient = SocketIOClient(socketURL: productionURL)
    var isConnected: Bool = false
    var connectedEvent: SocketEvent?
    var questionCallback: QuestionRecievedCallback?
    
    init(userToken: String) {
        self.userToken = userToken
        let params: [String: AnyObject] = ["Authorization" : "\(self.userToken)"]
        let s = SocketIOClient(socketURL: productionURL, opts: ["extraHeaders":params, "log":true])
        s.nsp = "/classroom"
        s.on("connect") { (data, ack) in
            self.isConnected = true
            print("Connected")
            self.connectedEvent?()
        }
        s.on("news") { (data, ack) in
            
        }
        s.on("disconnect") { (data, ack) -> Void in
            self.isConnected = false
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
        s.on("assignmentTerminated") { (data, ack) -> Void in
            //TODO: Check assignmentID
            self.questionCallback?(nil)
        }
        self.socket = s
    }
    func start() {
        print("Starting Connection")
        if !self.isConnected {
            self.socket.disconnect(fast: true)
            self.socket.connect(timeoutAfter: 10, withTimeoutHandler: nil);
        }
    }
    
    func submitAttendance(blob: String) {
        dispatch_after(1, dispatch_get_main_queue()) { () -> Void in
            print("emitting: \(blob)")
            self.socket.emitWithAck("attendance", blob)(timeoutAfter: 0, callback: { (stuff) -> Void in
                QL1Debug(stuff)
                if let stuff = stuff where stuff.firstObject != nil {
                    let json = JSON.parse(stuff.firstObject!)
                    
                    let course: Course = decode(stuff.firstObject!)!
                    
                    let parameter = Wrapper(value: course)
                    
                    let notification = NSNotification(name: "attendanceEvent", object: ["Course": parameter])
                    NSNotificationCenter.defaultCenter().postNotification(notification)
                    
                    let questions: [MultipleChoiceQuestion]? = json <|| "assignments"
                    if let question = questions?.last {
                        if question.dueTime.compare(NSDate(timeIntervalSinceNow: 2)) == NSComparisonResult.OrderedDescending {
                            delay(1, closure: { () -> () in
                                self.questionCallback?(question)
                            })
                        }
                    }
                    
                    
                }
                
            })
        }
    }
    
    
    func parseQuestion(data: NSArray) -> MultipleChoiceQuestion {
        return decode(data.firstObject!)!
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

func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}
