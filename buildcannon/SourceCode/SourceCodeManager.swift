//
//  SourceCodeManager.swift
//  buildcannon
//
//  Created by Anderson Lucas C. Ramos on 27/10/18.
//  Copyright © 2018 InsaniTech. All rights reserved.
//

import Foundation

class SourceCodeManager {
    func createDirectories() {
        if !FileManager.default.fileExists(atPath: baseTempDir) {
            try! FileManager.default.createDirectory(atPath: baseTempDir, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    func removeCacheDir() {
        do {
            try FileManager.default.removeItem(atPath: baseTempDir)
        } catch let error {
            Console.log(message: "Tried to delete build path but failed: \(baseTempDir)")
            Console.log(message: "Error: \(error.localizedDescription)")
        }
    }
    
    func copySourceCode() {
        do {
            try FileManager.default.createDirectory(at: sourceCodeTempDir, withIntermediateDirectories: true, attributes: nil)
            let contents = try FileManager.default.contentsOfDirectory(atPath: FileManager.default.currentDirectoryPath)
                .filter({
                    #if !DEBUG
                    return !$0.hasPrefix(".") && $0 != "Pods"
                    #else
                    return $0 != "Pods"
                    #endif
                })
                .map({
                    (from: URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent($0),
                     to: sourceCodeTempDir.appendingPathComponent($0))
                })
            try contents.forEach({
                #if DEBUG
                Console.log(message: "Copying file from \"\($0.from.path)\" to \"\($0.to.path)\"")
                #endif
                try FileManager.default.copyItem(at: $0.from, to: $0.to)
            })
        } catch let error as NSError {
            Console.log(message: "Coudn't copy source contents, interrupting...")
            Console.log(message: "Error: \(error.localizedDescription)")
            self.deleteSourceCode()
            application.interrupt(code: error.code)
        }
    }
    
    func deleteSourceCode() {
        #if !DEBUG
        try? FileManager.default.removeItem(at: sourceCodeTempDir)
        #endif
    }
}
