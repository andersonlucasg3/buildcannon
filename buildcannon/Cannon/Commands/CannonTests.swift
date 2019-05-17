//
//  CannonTests.swift
//  buildcannon
//
//  Created by Anderson Lucas C. Ramos on 17/05/19.
//  Copyright © 2019 InsaniTech. All rights reserved.
//

import Foundation

class CannonTests: CannonDistribute {
    override func execute() {
        if self.validateRequiredParameters(dependency: CannonParameter.runTests.dependency) {
            super.execute()
        } else {
            application.interrupt(code: -1)
        }
    }
    
    override func executeArchive() {
        Console.log(message: "Starting tests at path: \(BuildcannonProcess.workingDir(wasSourceCopied: application.shouldCopyCode).path)")
        
        let testsExecutor = TestsExecutor.init(project: self.findValue(for: InputParameter.Project.projectFile.name),
                                               target: self.findValue(for: InputParameter.Project.target.name),
                                               scheme: self.findValue(for: InputParameter.Project.scheme.name)!,
                                               sdk: self.findValue(for: InputParameter.Project.sdk.name),
                                               platform: self.findValue(for: InputParameter.Project.platform.name)!,
                                               device: self.findValue(for: InputParameter.Project.device.name)!,
                                               osVersion: self.findValue(for: InputParameter.Project.osVersion.name)!)
        testsExecutor.delegate = self
        testsExecutor.execute()
        self.currentExecutor = testsExecutor
    }
    
    override func executorDidFinishWithSuccess(_ executor: ExecutorProtocol) {
        switch executor {
        case is TestsExecutor: self.testsExecutorDidFinishWithSuccess()
        case is CannonPreBuild: self.preBuildCommandExecutorDidFinishWithSuccess()
        default: break
        }
    }
    
    override func executor(_ executor: ExecutorProtocol, didFailWithErrorCode code: Int) {
        switch executor {
        case is TestsExecutor: self.testsExecutorDidFailWithErrorCode(code)
        case is CannonPreBuild: self.preBuildCommandExecutorDidFailWithErrorCode(code)
        default: break
        }
    }
    
    fileprivate func testsExecutorDidFinishWithSuccess() {
        application.sourceCodeManager.deleteSourceCode()
        
        Console.log(message: "Tests finished with success for target \(self.currentTarget)")
        
        self.dequeueAndExecuteNextTargetIfNeeded(exitCode: 0)
    }
    
    fileprivate func testsExecutorDidFailWithErrorCode(_ code: Int) {
        let platformParam: DoubleDashComplexParameter? = self.findValue(for: InputParameter.Project.platform.name)
        let osVersionParam: DoubleDashComplexParameter? = self.findValue(for: InputParameter.Project.osVersion.name)
        let testLog = TestTool.Values.testsLogPath(platform: platformParam?.composition ?? "unknown", osVersion: osVersionParam?.composition ?? "unknown")
        
        Console.log(message: "Tests failed with status code \(code) for target \(self.currentTarget)")
        Console.log(message: "See logs at: \(testLog)")
        
        // if any test flow fails, we stop with error immediatelly.
        application.interrupt(code: code)
    }
}
