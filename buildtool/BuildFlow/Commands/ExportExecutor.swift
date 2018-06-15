//
//  ExportExecutor.swift
//  buildtool
//
//  Created by Anderson Lucas C. Ramos on 15/06/18.
//  Copyright © 2018 InsaniTech. All rights reserved.
//

import Foundation

protocol ExportExecutorProtocol: class {
    func exportExecutorDidFinishWithSuccess()
    func exportExecutorDidFinishWithFailCode(_ code: Int)
}

class ExportExecutor: ExecutorProtocol {
    fileprivate var commandExecutor: CommandExecutor!
    fileprivate let teamId: DoubleDashComplexParameter
    fileprivate let bundleIdentifier: DoubleDashComplexParameter
    fileprivate let provisioningProfile: DoubleDashComplexParameter
    fileprivate let includeBitcode: Bool
    
    weak var delegate: ExportExecutorProtocol?
    
    init(teamId: DoubleDashComplexParameter, bundleIdentifier: DoubleDashComplexParameter,
         provisioningProfileName: DoubleDashComplexParameter, includeBitcode: Bool = false) {
        self.teamId = teamId
        self.bundleIdentifier = bundleIdentifier
        self.provisioningProfile = provisioningProfileName
        self.includeBitcode = includeBitcode
        
        self.commandExecutor = CommandExecutor.init(path: "/usr/bin/", application: ExportTool.toolName, logFilePath: ExportTool.Values.exportLogPath)
        self.commandExecutor.add(parameter: SingleDashParameter.init(parameter: ExportTool.Parameters.exportArchive))
        self.commandExecutor.add(parameter: SingleDashComplexParameter.init(parameter: ExportTool.Parameters.archivePath, composition: ArchiveTool.Values.archivePath))
        self.commandExecutor.add(parameter: SingleDashComplexParameter.init(parameter: ExportTool.Parameters.exportOptionsPlistPath, composition: ExportTool.Values.exportPlistPath))
        self.commandExecutor.add(parameter: SingleDashComplexParameter.init(parameter: ExportTool.Parameters.exportPath, composition: ExportTool.Values.exportPath))
        self.commandExecutor.add(parameter: SingleDashParameter.init(parameter: ExportTool.Parameters.allowProvisioningUpdates))
    }
    
    fileprivate func createExportOptionsFile() {
        let fileString = """
        <?xml version=\"1.0\" encoding=\"UTF-8\"?>
        <!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
        <plist version=\"1.0\">
        <dict>
        <key>method</key>
        <string>app-store</string>
        <key>teamID</key>
        <string>\(self.teamId.composition)</string>
        <key>signingCertificate</key>
        <string>iPhone Distribution</string>
        <key>signingStyle</key>
        <string>manual</string>
        <key>uploadSymbols</key>
        <true/>
        <key>uploadBitcode</key>
        <\(self.includeBitcode)/>
        <key>provisioningProfiles</key>
        <dict>
        <key>\(self.bundleIdentifier.composition)</key>
        <string>\(self.provisioningProfile.composition)</string>
        </dict>
        </dict>
        </plist>
        """
        try! fileString.write(toFile: ExportTool.Values.exportPlistPath, atomically: true, encoding: .utf8)
    }
    
    fileprivate func dispatchFinish(_ returnCode: Int) {
        DispatchQueue.main.async { [weak self] in
            if returnCode == 0 {
                self?.delegate?.exportExecutorDidFinishWithSuccess()
            } else {
                self?.delegate?.exportExecutorDidFinishWithFailCode(returnCode)
            }
        }
    }
    
    func execute() {
        Logger.log(message: "Executing export IPA with command: \(self.commandExecutor.buildCommandString())")
        self.createExportOptionsFile()
        self.commandExecutor.execute { [weak self] (returnCode, _) in
            self?.dispatchFinish(returnCode)
        }
    }
    
    func cancel() {
        self.commandExecutor.stop()
    }
}
