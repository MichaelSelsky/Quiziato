//
//  SocketClient.swift
//  NJITQuizApp
//
//  Created by MichaelSelsky on 9/22/15.
//  Copyright © 2015 self. All rights reserved.
//

import Foundation
import Socket_IO_Client_Swift

class SocketClient {
    var socket: SocketIOClient {
        let s = SocketIOClient(socketURL: "http://quiz-dev.herokuapp.com")
        s.nsp = "/classroom"
        s.on("connect") { (data, ack) in
            print ("Connected")
            s.emit("attendance", "socket1")
            let d = "Hi Trevor!".dataUsingEncoding(NSUTF8StringEncoding)
            s.emit("data_test", d)
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
        return s
        
    }
    func start() {
        self.socket.connect(timeoutAfter: 60, withTimeoutHandler: nil)

    }
    
}
