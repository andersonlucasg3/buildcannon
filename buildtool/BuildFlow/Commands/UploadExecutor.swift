//
//  UploadExecutor.swift
//  buildtool
//
//  Created by Anderson Lucas C. Ramos on 15/06/18.
//  Copyright © 2018 InsaniTech. All rights reserved.
//

import Foundation

protocol UploadExecutorProtocol: class {
    func uploadExecutorDidFinishWithSuccess()
    func uploadExecutorDidFailWithErrorCode(_ code: Int)
}

class UploadExecutor: ExecutorProtocol {
    fileprivate var commandExecutor: CommandExecutor!
    
    weak var delegate: UploadExecutorProtocol?
    
    init(userName: DoubleDashComplexParameter, password: DoubleDashComplexParameter) {
        self.commandExecutor = CommandExecutor.init(path: UploadTool.toolPath, application: UploadTool.toolName, logFilePath: UploadTool.Values.uploadLogPath)
        self.commandExecutor.logExecution = Application.isVerbose
        self.commandExecutor.add(parameter: DoubleDashParameter.init(parameter: UploadTool.Parameters.uploadApp))
        self.commandExecutor.add(parameter: SingleDashComplexParameter.init(parameter: UploadTool.Parameters.file, composition: ExportTool.Values.exportPath))
        self.commandExecutor.add(parameter: SingleDashComplexParameter.init(parameter: UploadTool.Parameters.username, composition: userName.composition))
        self.commandExecutor.add(parameter: SingleDashComplexParameter.init(parameter: UploadTool.Parameters.password, composition: password.composition))
    }
    
    fileprivate func dispatchFinished(_ returnCode: Int) {
        DispatchQueue.main.async { [weak self] in
            if returnCode == 0 {
                self?.delegate?.uploadExecutorDidFinishWithSuccess()
            } else {
                self?.delegate?.uploadExecutorDidFailWithErrorCode(returnCode)
            }
        }
    }
    
    func execute() {
        Console.log(message: "Executing IPA's upload...")
        
        self.commandExecutor.execute { [weak self] (returnCode, _) in
            self?.dispatchFinished(returnCode)
        }
    }
    
    func cancel() {
        self.commandExecutor.stop()
    }
}
