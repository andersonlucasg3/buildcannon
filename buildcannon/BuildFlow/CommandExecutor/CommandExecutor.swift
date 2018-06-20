//
//  CommandExecutor.swift
//  buildcannon
//
//  Created by Anderson Lucas C. Ramos on 13/06/18.
//  Copyright © 2018 InsaniTech. All rights reserved.
//

import Foundation

typealias CommandExecutorCompletion = (_ returnCode: Int, _ output: String?) -> Void

class CommandExecutor {
    fileprivate let applicationPath: String
    fileprivate let applicationName: String
    fileprivate let logFilePath: String?
    fileprivate var parameters: [CommandParameter]

    fileprivate var proccessThread: Thread!
    fileprivate var process: Process!
    fileprivate var pipe: Pipe!
    fileprivate var logFileHandle: FileHandle!
    fileprivate var dataAvailableObserver: NSObjectProtocol!
    
    var logExecution: Bool = true
    
    init(path: String, application: String, logFilePath: String?) {
        self.applicationPath = path
        self.applicationName = application
        self.logFilePath = logFilePath
        self.parameters = Array()
    }
    
    deinit {
        self.clear()
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
    
    fileprivate func logData(_ data: Data) {
        if self.logExecution {
            if let str = String.init(data: data, encoding: .utf8) {
                Console.log(message: str, terminator: "")
            } else {
                Console.log(message: "Not valid data string.")
            }
        }
    }
    
    fileprivate func waitForData() {
        self.dataAvailableObserver = NotificationCenter.default.addObserver(forName: .NSFileHandleDataAvailable, object: nil, queue: nil) { [weak self] (notification) in
            guard let fileHandle = notification.object as? FileHandle else {
                self?.clear()
                return
            }
            let data = fileHandle.availableData
            if data.count > 0 {
                self?.logFileHandle?.write(data)
                self?.logData(data)
            }
            self?.pipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
        }
        self.pipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
    }
    
    func execute(tag: String, completion: @escaping CommandExecutorCompletion) {
        if #available(macOS 10.12, *) {
            self.proccessThread = Thread.init {
                self.threadRun(completion: completion)
            }
        } else {
            self.proccessThread = Thread.init(target: self, selector: #selector(self.threadRun(completion:)), object: completion)
        }
        self.proccessThread.name = tag
        self.proccessThread.start()
    }
    
    @objc fileprivate func threadRun(completion: CommandExecutorCompletion) {
        self.process = Process.init()
        self.process.qualityOfService = QualityOfService.userInitiated
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
        let output = try? String.init(contentsOfFile: self.logFilePath ?? "")
        completion(Int.init(self.process.terminationStatus), output)
        
        self.clear()
    }
    
    fileprivate func clear() {
        NotificationCenter.default.removeObserver(self.dataAvailableObserver)
        self.process = nil
        self.proccessThread = nil
    }
    
    func stop() {
        self.proccessThread?.cancel()
        self.process?.interrupt()
        self.clear()
    }
    
    func buildCommandString() -> String {
        var commandString = self.applicationPath + self.applicationName
        self.parameters.forEach { (parameter) in
            commandString = "\(commandString) \(parameter.buildParameter())"
        }
        return commandString
    }
}
