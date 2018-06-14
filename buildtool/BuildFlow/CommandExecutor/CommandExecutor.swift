//
//  CommandExecutor.swift
//  buildtool
//
//  Created by Anderson Lucas C. Ramos on 13/06/18.
//  Copyright © 2018 Anderson Lucas C. Ramos. All rights reserved.
//

import Foundation

typealias CommandExecutorCompletion = ((_ returnCode: Int, _ output: String) -> Void)

class CommandExecutor {
    fileprivate let applicationPath: String
    fileprivate let applicationName: String
    fileprivate var parameters: [CommandParameter]

    fileprivate var process: Process!
    fileprivate var pipe: Pipe!
    fileprivate var logFileHandle: FileHandle!
    fileprivate var dataAvailableObserver: NSObjectProtocol!
    
    init(path: String, application: String) {
        self.applicationPath = path
        self.applicationName = application
        self.parameters = Array()
    }
    
    func add(parameter: CommandParameter) {
        self.parameters.append(parameter)
    }
    
    fileprivate func setupFileHandlers() {
        FileManager.default.createFile(atPath: ArchiveTool.Values.archiveLogPath, contents: nil, attributes: nil)
        self.logFileHandle = FileHandle.init(forWritingAtPath: ArchiveTool.Values.archiveLogPath)
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
                self?.logFileHandle.write(data)
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
            self.process.arguments = ["-c", "\(self.buildCommandString()) | xcpretty"] //self.parameters.map({ $0.buildParameter().components(separatedBy: " ") }).flatMap({$0})
            self.process.executableURL = URL.init(fileURLWithPath: "file:///bin/sh") // \(self.applicationPath)\(self.applicationName)
            self.setupFileHandlers()
            self.waitForData()
            self.process.launch()
            self.process.waitUntilExit()

            self.logFileHandle.closeFile()
            DispatchQueue.main.async {
                completion(Int.init(self.process.terminationStatus), (try? String.init(contentsOfFile: ArchiveTool.Values.archiveLogPath)) ?? "")
            }
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
