//
//  CannonPreBuild.swift
//  buildcannon
//
//  Created by Anderson Lucas C. Ramos on 19/06/18.
//  Copyright © 2018 InsaniTech. All rights reserved.
//

import Foundation

class CannonPreBuild: ExecutorProtocol {
    fileprivate var preBuildCommands: [String]!
    
    fileprivate var currentExecutor: CommandExecutor!
    
    weak var delegate: ExecutorCompletionProtocol?
    
    required init() {
    
    }
    
    convenience init(preBuildCommands: [String]) {
        self.init()
        self.preBuildCommands = preBuildCommands
    }
    
    func execute() {
        self.startPreBuildOrFinish()
    }
    
    func cancel() {
        self.currentExecutor.stop()
    }
    
    fileprivate func startPreBuildOrFinish() {
        if self.preBuildCommands.count > 0 {
            self.executePreBuildCommand(self.preBuildCommands.first!)
        } else {
            self.dispatchFinish()
        }
    }
    
    fileprivate func executePreBuildCommand(_ command: String) {
        let executor = CommandExecutor.init(path: "", application: command, logFilePath: "\(baseTempDir)/preBuildCommand.log")
        executor.executeOnDirectoryPath = sourceCodeTempDir.path
        executor.execute(tag: "command") { (result, output) in
            guard result == 0 else {
                Application.execute {
                    self.dispatchFail(result)
                }
                return
            }
            Application.execute {
                self.preBuildCommands.removeFirst()
                self.startPreBuildOrFinish()
            }
        }
        self.currentExecutor = executor
    }
    
    fileprivate func dispatchFinish() {
        self.delegate?.executorDidFinishWithSuccess(self)
    }
    
    fileprivate func dispatchFail(_ code: Int) {
        Console.log(message: "Failed to execute pre-build command: \(self.preBuildCommands.first!)")
        self.delegate?.executor(self, didFailWithErrorCode: code)
    }
}
