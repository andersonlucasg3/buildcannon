//
//  CannonUpload.swift
//  buildcannon
//
//  Created by Anderson Lucas C. Ramos on 29/10/18.
//  Copyright © 2018 InsaniTech. All rights reserved.
//

import Foundation

class CannonUpload: CannonExport {
    override func execute() {
        if self.validateRequiredParameters() {
            self.executeUpload()
        } else {
            application.interrupt()
        }
    }
    
    fileprivate func validateRequiredParameters() -> Bool {
        Console.log(message: "Parameters: \(Application.processParameters.map({$0.parameter}).joined(separator: ","))")
        if let dependencies = CannonParameter.upload.dependency {
            for dep in dependencies {
                if !Application.processParameters.contains(where: {$0.parameter.contains(dep.name)}) {
                    Console.log(message: "Required parameter not informed: \(dep.name)")
                    return false
                }
            }
        }
        return true
    }
    
    override func uploadExecutorDidFinishWithSuccess() {
        Console.log(message: "Upload finished with success")
    }
}
