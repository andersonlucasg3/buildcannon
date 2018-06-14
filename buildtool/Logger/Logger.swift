//
//  Logger.swift
//  buildtool
//
//  Created by Anderson Lucas C. Ramos on 14/06/18.
//  Copyright © 2018 Anderson Lucas C. Ramos. All rights reserved.
//

import Foundation

class Logger {
    fileprivate static let fileOutputStream = OutputStream.init(toFileAtPath: baseTempDir + "/buildtool.log", append: false)
    
    static func log(message: String) {
        print(message)
        self.fileOutputStream?.write(message, maxLength: message.count)
    }
    
    static func closeLog() {
        self.fileOutputStream?.close()
    }
    
    private init() { }
}
