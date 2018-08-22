//
//  ExportExecutor.swift
//  buildcannon
//
//  Created by Anderson Lucas C. Ramos on 15/06/18.
//  Copyright © 2018 InsaniTech. All rights reserved.
//

import Foundation

class ExportExecutor: ExecutorProtocol {
    fileprivate var commandExecutor: CommandExecutor!
    fileprivate var teamId: DoubleDashComplexParameter!
    fileprivate var bundleIdentifier: DoubleDashComplexParameter!
    fileprivate var topShelfBundleIdentifier: DoubleDashComplexParameter!
    fileprivate var provisioningProfile: DoubleDashComplexParameter!
    fileprivate var topShelfProvisioningProfile: DoubleDashComplexParameter!
    fileprivate var exportMethod: DoubleDashComplexParameter?
    fileprivate var tvosExport: Bool = false
    fileprivate var includeBitcode: Bool = false
    
    weak var delegate: ExecutorCompletionProtocol?
    
    required init() {
    
    }
    
    convenience init(archivePath: DoubleDashComplexParameter? = nil,
                     teamId: DoubleDashComplexParameter,
                     bundleIdentifier: DoubleDashComplexParameter,
                     topShelfBundleIdentifier: DoubleDashComplexParameter?,
                     provisioningProfileName: DoubleDashComplexParameter,
                     topShelfProvisioningProfile: DoubleDashComplexParameter?,
                     exportMethod: DoubleDashComplexParameter?,
                     tvosExport: Bool = false,
                     includeBitcode: Bool = false) {
        self.init()
        
        self.teamId = teamId
        self.bundleIdentifier = bundleIdentifier
        self.topShelfBundleIdentifier = topShelfBundleIdentifier
        self.provisioningProfile = provisioningProfileName
        self.topShelfProvisioningProfile = topShelfProvisioningProfile
        self.exportMethod = exportMethod
        self.tvosExport = tvosExport
        self.includeBitcode = includeBitcode
        
        self.commandExecutor = CommandExecutor.init(path: "/usr/bin/", application: ExportTool.toolName, logFilePath: ExportTool.Values.exportLogPath)
        self.commandExecutor.logExecution = Application.isVerbose
        self.commandExecutor.add(parameter: SingleDashParameter.init(parameter: ExportTool.Parameters.exportArchive))
        self.commandExecutor.add(parameter: SingleDashComplexParameter.init(parameter: ExportTool.Parameters.archivePath, composition: archivePath?.composition ?? ArchiveTool.Values.archivePath))
        self.commandExecutor.add(parameter: SingleDashComplexParameter.init(parameter: ExportTool.Parameters.exportOptionsPlistPath, composition: ExportTool.Values.exportPlistPath))
        self.commandExecutor.add(parameter: SingleDashComplexParameter.init(parameter: ExportTool.Parameters.exportPath, composition: ExportTool.Values.exportPath))
        self.commandExecutor.add(parameter: SingleDashParameter.init(parameter: ExportTool.Parameters.allowProvisioningUpdates))
    }
    
    fileprivate func createExportOptionsFile() {
        var provisioningProfiles = """
        <key>\(self.bundleIdentifier.composition)</key>
        <string>\(self.provisioningProfile.composition)</string>
        """
        if let topShelfBundle = self.topShelfBundleIdentifier,
            let topShelfProv = self.topShelfProvisioningProfile,
            self.tvosExport {
            provisioningProfiles = """
            <key>\(self.bundleIdentifier.composition)</key>
            <string>\(self.provisioningProfile.composition)</string>
            <key>\(topShelfBundle.composition)</key>
            <string>\(topShelfProv.composition)</string>
            """
        }
        
        let fileString = """
        <?xml version=\"1.0\" encoding=\"UTF-8\"?>
        <!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
        <plist version=\"1.0\">
        <dict>
        <key>method</key>
        <string>\(self.exportMethod?.composition ?? "app-store")</string>
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
        <key>compileBitcode</key>
        <\(self.includeBitcode)/>
        <key>provisioningProfiles</key>
        <dict>
        \(provisioningProfiles)
        </dict>
        </dict>
        </plist>
        """
        try! fileString.write(toFile: ExportTool.Values.exportPlistPath, atomically: true, encoding: .utf8)
    }
    
    fileprivate func dispatchFinish(_ returnCode: Int) {
        Application.execute { [weak self] in
            if returnCode == 0 {
                self?.delegate?.executorDidFinishWithSuccess(self!)
            } else {
                self?.delegate?.executor(self!, didFailWithErrorCode: returnCode)
            }
        }
    }
    
    func execute() {
        Console.log(message: "Executing export IPA with command: \(self.commandExecutor.buildCommandString())")
        self.createExportOptionsFile()
        self.commandExecutor.execute(tag: "ExportExecutor") { [weak self] (returnCode, _) in
            self?.dispatchFinish(returnCode)
        }
    }
    
    func cancel() {
        self.commandExecutor.stop()
    }
}
