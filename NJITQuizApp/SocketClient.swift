//
//  SocketClient.swift
//  NJITQuizApp
//
//  Created by MichaelSelsky on 9/22/15.
//  Copyright © 2015 self. All rights reserved.
//

import Foundation
import Socket_IO_Client_Swift

enum SocketMessage{
    case SubmitAttendance(blob: NSData)
}

typealias SocketEvent = () -> ()

class SocketClient {
    let userToken: String
    var socket: SocketIOClient = SocketIOClient(socketURL: "http://quiz-dev.herokuapp.com")
    var connectedEvent: SocketEvent?
    
//        {
//        let params: [String: AnyObject] = ["Authorization" : "\(self.userToken)"]
//        let s = SocketIOClient(socketURL: "http://quiz-dev.herokuapp.com", opts: ["extraHeaders":params, "log":true])
//        s.nsp = "/classroom"
//        s.on("connect") { (data, ack) in
//            print("Connected")
//            self.submitAttendance("QRCode")
//        }
//        s.on("news") { (data, ack) in
//            
//        }
//        s.on("disconnect") { (data, ack) -> Void in
//            print("Disconnected")
//        }
//        s.on("error") { (data, ack) -> Void in
//            print("error")
//        }
//        s.on("question") { (data, ack) -> Void in
//            print(data![0])
//        }
//        
//        return s
//    }
    
    init(userToken: String) {
        self.userToken = userToken
        let params: [String: AnyObject] = ["Authorization" : "\(self.userToken)"]
        let s = SocketIOClient(socketURL: "http://quiz-dev.herokuapp.com", opts: ["extraHeaders":params, "log":true])
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
        s.on("question") { (data, ack) -> Void in
            print(data![0])
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
            })
        }
    }
    
}
