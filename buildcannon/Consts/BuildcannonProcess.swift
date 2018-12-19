//
//  BuildcannonProcess.swift
//  buildcannon
//
//  Created by Anderson Lucas de Castro Ramos on 18/12/18.
//  Copyright © 2018 InsaniTech. All rights reserved.
//

import Foundation

let baseTempDir = NSTemporaryDirectory() + UUID.init().uuidString

class BuildcannonProcess {
    class func workingDir(wasSourceCopied: Bool) -> URL {
        let sourceCodeTempDir = URL(fileURLWithPath: baseTempDir).appendingPathComponent("sourcecode")
        let processWorkingDir = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        
        return wasSourceCopied ? sourceCodeTempDir : processWorkingDir
    }
}
