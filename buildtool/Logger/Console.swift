//
//  Logger.swift
//  buildtool
//
//  Created by Anderson Lucas C. Ramos on 14/06/18.
//  Copyright © 2018 InsaniTech. All rights reserved.
//

import Foundation

class Console {
    fileprivate static var fileOutputStream = OutputStream.init(toFileAtPath: baseTempDir + "/buildtool.log", append: false)
    
    class func log(message: String, terminator: String = "\n") {
        print(message, terminator: terminator)
        self.fileOutputStream?.write(message, maxLength: message.count)
    }
    
    class func readInput(message: String, readCallback: ((_ value: String?) -> Void)) {
        self.log(message: message, terminator: "")
        let line = readLine()
        let outputMessage = line ?? "not informed"
        self.fileOutputStream?.write(outputMessage, maxLength: outputMessage.count)
        readCallback(line)
    }
    
    class func readInputSecure(message: String, readCallback: ((_ value: String?) -> Void)) {
        let buf = [Int8].init(repeating: 0, count: 8192)
        if let pass = readpassphrase(message, UnsafeMutablePointer<Int8>.init(mutating: buf), buf.count, 0) {
            let passStr = String.init(validatingUTF8: pass)
            let outputPassStr = passStr ?? "not informed"
            self.fileOutputStream?.write(message + outputPassStr, maxLength: outputPassStr.count)
            readCallback(passStr)
        } else {
            readCallback(nil)
        }
    }
    
    class func closeLog() {
        self.fileOutputStream?.close()
    }
    
    private init() { }
}
