//
//  CommandExport.swift
//  buildcannon
//
//  Created by Anderson Lucas de Castro Ramos on 17/08/18.
//  Copyright © 2018 InsaniTech. All rights reserved.
//

import Foundation

class CannonExport: CannonDistribute {
    override func executePreBuild(file: CannonFile) {
        if self.validateRequiredParameters(dependency: CannonParameter.export.dependency) {
            super.executePreBuild(file: file)
        } else {
            application.interrupt(code: -1)
        }
    }
    
    fileprivate func moveIpaToOutputPath() {
        let ipaPath = self.getIpaPath()
        if let outputPath: DoubleDashComplexParameter = self.findValue(for: InputParameter.Output.outputPath.name) {
            do {
                try FileManager.default.moveItem(atPath: ipaPath, toPath: "\(outputPath.composition)/\(self.currentTarget).ipa")
            } catch let error {
                Console.log(message: "Error moving output to provided path: \(error)\nOutput path: \(outputPath.composition)")
            }
        } else {
            Console.log(message: "Output path not provided, IPA is available at: \(ipaPath)")
        }
    }
    
    override func exportExecutorDidFinishWithSuccess() {
        Console.log(message: "Export finished with success for target \(self.currentTarget).")
        
        self.moveIpaToOutputPath()
        
        self.dequeueAndExecuteNextTargetIfNeeded(exitCode: 0)
    }
}
