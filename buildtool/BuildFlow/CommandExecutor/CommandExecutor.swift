//
//  CommandExecutor.swift
//  buildtool
//
//  Created by Anderson Lucas C. Ramos on 13/06/18.
//  Copyright © 2018 Anderson Lucas C. Ramos. All rights reserved.
//

import Foundation

typealias CommandExecutorCompletion = (_ returnCode: Int) -> Void

class CommandExecutor {
    fileprivate let applicationPath: String
    fileprivate let applicationName: String
    fileprivate let logFilePath: String?
    fileprivate var parameters: [CommandParameter]

    fileprivate var process: Process!
    fileprivate var pipe: Pipe!
    fileprivate var logFileHandle: FileHandle!
    fileprivate var dataAvailableObserver: NSObjectProtocol!
    
    init(path: String, application: String, logFilePath: String?) {
        self.applicationPath = path
        self.applicationName = application
        self.logFilePath = logFilePath
        self.parameters = Array()
    }
    
    func add(parameter: CommandParameter) {
        self.parameters.append(parameter)
    }
    
    fileprivate func setupFileHandlers() {
        if let logFilePath = self.logFilePath {
            FileManager.default.createFile(atPath: logFilePath, contents: nil, attributes: nil)
            self.logFileHandle = FileHandle.init(forWritingAtPath: logFilePath)
        }
        self.pipe = Pipe.init()
        self.process.standardOutput = self.pipe
        self.process.standardError = self.pipe
    }
    
    fileprivate func waitForData() {
        self.dataAvailableObserver = NotificationCenter.default.addObserver(forName: .NSFileHandleDataAvailable, object: nil, queue: nil) { [weak self] (notification) in
            guard let fileHandle = notification.object as? FileHandle else {
                self?.removeObserver()
                return
            }
            let data = fileHandle.availableData
            if data.count > 0 {
                self?.logFileHandle?.write(data)
                if let str = String.init(data: data, encoding: .utf8) {
                    Logger.log(message: str, terminator: "")
                } else {
                    Logger.log(message: "Not valid data string.")
                }
            }
            self?.pipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
        }
        self.pipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
    }
    
    func execute(completion: @escaping CommandExecutorCompletion) {
        let thread = Thread.init { [unowned self] in
            self.process = Process.init()
            self.process.arguments = ["-c", "\(self.buildCommandString())"] //self.parameters.map({ $0.buildParameter().components(separatedBy: " ") }).flatMap({$0})
            if #available(OSX 10.13, *) {
                self.process.executableURL = URL.init(fileURLWithPath: "file:///bin/sh") // \(self.applicationPath)\(self.applicationName)
            } else {
                self.process.launchPath = "/bin/sh"
            }
            self.setupFileHandlers()
            self.waitForData()
            self.process.launch()
            self.process.waitUntilExit()

            self.logFileHandle?.closeFile()
            completion(Int.init(self.process.terminationStatus))
        }
        thread.start()
    }
    
    fileprivate func removeObserver() {
        NotificationCenter.default.removeObserver(self.dataAvailableObserver)
    }
    
    func stop() {
        self.removeObserver()
        self.process?.interrupt()
    }
    
    func buildCommandString() -> String {
        var commandString = self.applicationPath + self.applicationName
        self.parameters.forEach { (parameter) in
            commandString = "\(commandString) \(parameter.buildParameter())"
        }
        return commandString
    }
}
