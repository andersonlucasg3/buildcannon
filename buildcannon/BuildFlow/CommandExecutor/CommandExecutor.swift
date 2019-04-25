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

    fileprivate var process: Process!
    fileprivate var pipe: Pipe!
    fileprivate var logFileHandle: FileHandle!
    fileprivate var dataAvailableObserver: NSObjectProtocol!
    
    var logExecution: Bool = true
    var executeOnDirectoryPath: String?
    
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
    
    fileprivate func setShExecutable(_ process: Process) {
        if #available(OSX 10.13, *) {
            process.executableURL = URL.init(fileURLWithPath: "file:///bin/sh")
        } else {
            process.launchPath = "/bin/sh"
        }
    }
    
    func execute(tag: String, completion: @escaping CommandExecutorCompletion) {
        DispatchQueue.init(label: tag, qos: .userInitiated, attributes: .concurrent, autoreleaseFrequency: .inherit, target: DispatchQueue.global()).async {
            self.threadRun(completion: completion)
        }
    }
    
    @objc fileprivate func threadRun(completion: CommandExecutorCompletion) {
        self.process = Process.init()
        
        if let executeDirPath = self.executeOnDirectoryPath {
            self.process.currentDirectoryPath = executeDirPath
        }
        
        self.process.qualityOfService = QualityOfService.userInitiated
        self.process.arguments = ["-c", "\(self.buildCommandString())"]
        
        self.setShExecutable(self.process)
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
        NotificationCenter.default.removeObserver(self.dataAvailableObserver!)
        self.process = nil
    }
    
    func stop() {
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
