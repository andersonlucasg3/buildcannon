//
//  UploadExecutor.swift
//  buildcannon
//
//  Created by Anderson Lucas C. Ramos on 15/06/18.
//  Copyright © 2018 InsaniTech. All rights reserved.
//

import Foundation

class UploadExecutor: ExecutorProtocol {
    fileprivate var commandExecutor: CommandExecutor!
    
    weak var delegate: ExecutorCompletionProtocol?
    
    required init() {
        
    }
    
    convenience init(ipaPath: String, userName: DoubleDashComplexParameter, password: DoubleDashComplexParameter) {
        self.init()
        self.commandExecutor = CommandExecutor.init(path: UploadTool.toolPath, application: UploadTool.toolName, logFilePath: UploadTool.Values.uploadLogPath)
        self.commandExecutor.logExecution = Application.isVerbose
        self.commandExecutor.add(parameter: DoubleDashParameter.init(parameter: UploadTool.Parameters.uploadApp))
        self.commandExecutor.add(parameter: SingleDashComplexParameter.init(parameter: UploadTool.Parameters.file, composition: ipaPath))
        self.commandExecutor.add(parameter: SingleDashComplexParameter.init(parameter: UploadTool.Parameters.username, composition: userName.composition))
        self.commandExecutor.add(parameter: SingleDashComplexParameter.init(parameter: UploadTool.Parameters.password, composition: password.composition))
    }
    
    fileprivate func dispatchFinished(_ returnCode: Int) {
        Application.execute { [weak self] in
            if returnCode == 0 {
                self?.delegate?.executorDidFinishWithSuccess(self!)
            } else {
                self?.delegate?.executor(self!, didFailWithErrorCode: returnCode)
            }
        }
    }
    
    func execute() {
        Console.log(message: "Executing IPA's upload...")
        
        self.commandExecutor.execute(tag: "UploadExecutor") { [weak self] (returnCode, _) in
            self?.dispatchFinished(returnCode)
        }
    }
    
    func cancel() {
        self.commandExecutor.stop()
    }
}
