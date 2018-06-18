//
//  CommandParametersChecker.swift
//  buildcannon
//
//  Created by Anderson Lucas C. Ramos on 13/06/18.
//  Copyright © 2018 InsaniTech. All rights reserved.
//

import Foundation

class CommandParametersChecker {
    fileprivate let parameters: [CommandParameter]
    
    init(parameters: [CommandParameter]) {
        self.parameters = parameters
    }
    
    func checkParameters() -> Bool {
        var containsAllRequired = true
        
        func run(_ parameters: [Parameters.ParameterTouple]) {
            parameters.forEach { (item) in
                containsAllRequired = containsAllRequired && self.parameters.contains(where: {
                    $0.parameter == item.name && type(of: $0) == item.type
                })
            }
        }
        
        if Application.isExportOnly {
            run(Parameters.exportOnlyRequiredParameters)
        } else if Application.isUploadOnly {
            run(Parameters.uploadOnlyRequiredParameters)
        } else {
            run(Parameters.fullProcessRequiredParameters)
        }
        return containsAllRequired
    }
    
    func checkHelp() -> Bool {
        return self.parameters.contains(where: {$0.parameter == Parameters.help.name})
    }
    
    func checkVerbose() -> Bool {
        return self.parameters.contains(where: {$0.parameter == Parameters.verbose.name})
    }
    
    func checkExportOnly() -> Bool {
        return self.parameters.contains(where: {$0.parameter == Parameters.exportOnly.name})
    }
    
    func checkUploadOnly() -> Bool {
        return self.parameters.contains(where: {$0.parameter == Parameters.uploadOnly.name})
    }
    
    func checkXcprettyInstalled(completion: @escaping (Bool) -> Void) {
        let executor = CommandExecutor.init(path: "/usr/bin/", application: "command", logFilePath: "\(baseTempDir)/checkXcprettyInstalled.log")
        executor.add(parameter: SingleDashComplexParameter.init(parameter: "-v", composition: "xcpretty"))
        executor.execute(tag: "CommandParametersChecker") { (code, output) in
            Application.execute {
                let success = !(output ?? "").isEmpty // !isEmpty means that the program exists
                completion(success)
            }
        }
    }
}
