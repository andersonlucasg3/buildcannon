//
//  CommandParametersChecker.swift
//  buildcannon
//
//  Created by Anderson Lucas C. Ramos on 13/06/18.
//  Copyright © 2018 InsaniTech. All rights reserved.
//

import Foundation

class ParametersChecker {
    fileprivate let separator = " "
    fileprivate let parameters: [CommandParameter]
    
    init(parameters: [CommandParameter]) {
        self.parameters = parameters
    }
    
    func checkHelp() -> Bool {
        return self.parameters.contains(where: {$0.parameter == InputParameter.help.name})
    }
    
    func checkVerbose() -> Bool {
        return self.parameters.contains(where: {$0.parameter == InputParameter.verbose.name})
    }
    
    func checkVersion() -> Bool {
        return self.parameters.contains(where: {$0.parameter == InputParameter.version.name})
    }
    
    func checkXcprettyInstalled(completion: @escaping (Bool) -> Void) {
        let executor = CommandExecutor.init(path: "/usr/bin/", application: "command", logFilePath: "\(baseTempDir)/checkXcprettyInstalled.log")
        executor.logExecution = Application.isVerbose
        executor.add(parameter: SingleDashComplexParameter.init(parameter: "-v", composition: "xcpretty", separator: self.separator))
        executor.execute(tag: "CommandParametersChecker") { (code, output) in
            Application.execute {
                let success = !(output ?? "").isEmpty // !isEmpty means that the program exists
                completion(success)
            }
        }
    }
}
