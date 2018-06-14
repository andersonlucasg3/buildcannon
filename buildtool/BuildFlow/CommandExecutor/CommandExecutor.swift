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
    
    init(path: String, application: String) {
        self.applicationPath = path
        self.applicationName = application
        self.parameters = Array()
    }
    
    func add(parameter: CommandParameter) {
        self.parameters.append(parameter)
    }
    
    fileprivate func setupFileHandlers() {
        let handler = FileHandle.init(forWritingAtPath: ArchiveTool.Values.archiveLogPath)
        self.process.standardOutput = handler
        self.process.standardError = handler
    }
    
    func execute(completion: @escaping CommandExecutorCompletion) {
        let thread = Thread.init { [unowned self] in
            self.process = Process.init()
            self.process.arguments = self.parameters.map({ $0.buildParameter().components(separatedBy: " ") }).flatMap({$0})
            self.process.executableURL = URL.init(fileURLWithPath: "file://\(self.applicationPath)\(self.applicationName)")
            self.setupFileHandlers()
            self.process.launch()
            self.process.waitUntilExit()

            DispatchQueue.main.async {
                completion(Int.init(self.process.terminationStatus), (try? String.init(contentsOfFile: ArchiveTool.Values.archiveLogPath)) ?? "")
            }
        }
        thread.start()
    }
    
    func stop() {
        self.process.interrupt()
    }
    
    func buildCommandString() -> String {
        var commandString = self.applicationPath + self.applicationName
        self.parameters.forEach { (parameter) in
            commandString = "\(commandString) \(parameter.buildParameter())"
        }
        return commandString
    }
}
