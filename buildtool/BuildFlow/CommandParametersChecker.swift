//
//  CommandParametersChecker.swift
//  buildtool
//
//  Created by Anderson Lucas C. Ramos on 13/06/18.
//  Copyright © 2018 InsaniTech. All rights reserved.
//

import Foundation

struct CommandParametersChecker {
    fileprivate let parameters: [CommandParameter]
    
    init(parameters: [CommandParameter]) {
        self.parameters = parameters
    }
    
    func checkParameters() -> Bool {
        var containsAllRequired = true
        Parameters.REQUIRED_PARAMETERS.forEach({ (item) in
            containsAllRequired = containsAllRequired && self.parameters.contains(where: {
                $0.parameter == item.name && type(of: $0) == item.type
            })
        })
        return containsAllRequired
    }
    
    func checkHelp() -> Bool {
        return self.parameters.contains(where: {$0.parameter == Parameters.help.name})
    }
    
    func checkVerbose() -> Bool {
        return self.parameters.contains(where: {$0.parameter == Parameters.verbose.name})
    }
    
    func checkXcprettyInstalled() -> Bool {
        let executer = CommandExecutor.init(path: "/usr/bin/", application: "command", logFilePath: "\(baseTempDir)/checkXcprettyInstalled.log")
        executer.logExecution = false
        executer.add(parameter: SingleDashComplexParameter.init(parameter: "-v", composition: "xcpretty"))
        var returnCode = -235919
        executer.execute { (code, output) in
            returnCode = (output ?? "").isEmpty ? 1 : 0 // 0 is success
        }
        while returnCode == -235919 { }
        return returnCode == 0
    }
}
