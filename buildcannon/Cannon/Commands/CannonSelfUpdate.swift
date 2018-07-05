//
//  CannonSelfUpdate.swift
//  buildcannon
//
//  Created by Anderson Lucas de Castro Ramos on 05/07/18.
//  Copyright © 2018 InsaniTech. All rights reserved.
//

import Foundation

class CannonSelfUpdate: ExecutorProtocol {
    weak var delegate: ExecutorCompletionProtocol?
    
    required init() {
        
    }
    
    func execute() {
        let commandExecutor = CommandExecutor.init(path: "/bin/", application: "sh", logFilePath: "\(baseTempDir)/buildcannon-update.log")
        commandExecutor.add(parameter: SingleDashParameter.init(parameter: "c \"$(curl -s https://raw.githubusercontent.com/andersonlucasg3/buildcannon/master/installer/install.sh)\""))
        commandExecutor.executeOnDirectoryPath = baseTempDir
        commandExecutor.logExecution = true
        commandExecutor.execute(tag: "self-update") { (result, output) in
            if result == 0 {
                self.delegate?.executorDidFinishWithSuccess(self)
            } else {
                self.delegate?.executor(self, didFailWithErrorCode: result)
            }
        }
    }
    
    func cancel() {
        
    }
}
