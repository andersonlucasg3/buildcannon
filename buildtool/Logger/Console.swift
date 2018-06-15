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
        self.log(message: line ?? "not informed", terminator: "")
        readCallback(line)
    }
    
    class func closeLog() {
        self.fileOutputStream?.close()
    }
    
    private init() { }
}
