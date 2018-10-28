//
//  CannonDistribute.swift
//  buildcannon
//
//  Created by Anderson Lucas C. Ramos on 19/06/18.
//  Copyright © 2018 InsaniTech. All rights reserved.
//

import Foundation

class CannonDistribute: ExecutorProtocol {
    fileprivate var currentExecutor: ExecutorProtocol!
    
    weak var delegate: ExecutorCompletionProtocol?
    
    required init() {
        
    }
    
    func execute() {
        application.sourceCodeManager.copySourceCode()
        
        var command: NoDashComplexParameter? = nil
        let value: NoDashParameter? = Application.processParameters.count > 1 ? Application.processParameters[1] as? NoDashParameter : nil
        if let value = value {
            command = NoDashComplexParameter.init(parameter: CannonParameter.distribute.name, composition: value.parameter)
            Console.log(message: "Cannon project \(value.parameter).cannon will be used.")
        }
        
        let fileLoader = CannonFileLoader.init()
        if let file = fileLoader.load(target: command?.composition) {
            fileLoader.assign(file: file)
            self.executePreBuild(file: file)
        } else {
            Console.log(message: "Cannon project file not exists.")
            self.delegate?.executor(self, didFailWithErrorCode: -1)
        }
    }
    
    func executePreBuild(file: CannonFile) {
        if let preBuild = file.pre_build_commands {
            self.startPreBuildCommandExecutor(preBuild)
        } else {
            self.executeArchive()
        }
    }
    
    func cancel() {
        self.currentExecutor.cancel()
    }
    
    func getIpaPath() -> String {
        let scheme: DoubleDashComplexParameter = self.findValue(for: InputParameter.scheme.name)!
        let ipaPathParameter: DoubleDashComplexParameter? = self.findValue(for: InputParameter.ipaPath.name)
        return ipaPathParameter?.composition ?? baseTempDir + "/\(scheme.composition).ipa"
    }
    
    fileprivate func startPreBuildCommandExecutor(_ preBuild: [String]) {
        Console.log(message: "Starting pre-build commands...")
        
        let executor = CannonPreBuild.init(preBuildCommands: preBuild)
        executor.delegate = self
        executor.execute()
        self.currentExecutor = executor
    }
    
    fileprivate func executeArchive() {
        Console.log(message: "Starting archive at path: \(sourceCodeTempDir.path)")
        
        let archiveExecutor = ArchiveExecutor.init(project: self.findValue(for: InputParameter.projectFile.name),
                                                   target: self.findValue(for: InputParameter.target.name),
                                                   sdk: self.findValue(for: InputParameter.sdk.name),
                                                   scheme: self.findValue(for: InputParameter.scheme.name)!,
                                                   configuration: self.findValue(for: InputParameter.configuration.name)!)
        archiveExecutor.delegate = self
        archiveExecutor.execute()
        self.currentExecutor = archiveExecutor
    }
    
    fileprivate func executeExport() {
        Console.log(message: "Starting export at path: \(baseTempDir)")
        
        let sdk: DoubleDashComplexParameter? = self.findValue(for: InputParameter.sdk.name)
        let tvosExport = (sdk?.composition ?? "").contains("appletvos")
        let exportExecutor = ExportExecutor.init(archivePath: self.findValue(for: InputParameter.archivePath.name),
                                                 teamId: self.findValue(for: InputParameter.teamId.name)!,
                                                 bundleIdentifier: self.findValue(for: InputParameter.bundleIdentifier.name)!,
                                                 topShelfBundleIdentifier: self.findValue(for: InputParameter.topShelfBundleIdentifier.name),
                                                 provisioningProfileName: self.findValue(for: InputParameter.provisioningProfile.name)!,
                                                 topShelfProvisioningProfile: self.findValue(for: InputParameter.topShelfProvisioningProfile.name),
                                                 exportMethod: self.findValue(for: InputParameter.exportMethod.name),
                                                 tvosExport: tvosExport,
                                                 includeBitcode: tvosExport)
        exportExecutor.delegate = self
        exportExecutor.execute()
        self.currentExecutor = exportExecutor
    }
    
    fileprivate func executeUpload() {
        Console.log(message: "Starting upload of IPA at path: \(ExportTool.Values.exportPath)")
        
        self.queryAccountIfNeeded()
        
        let uploadExecutor = UploadExecutor.init(ipaPath: self.getIpaPath(),
                                                 userName: self.findValue(for: InputParameter.username.name)!,
                                                 password: self.findValue(for: InputParameter.password.name)!)
        uploadExecutor.delegate = self
        uploadExecutor.execute()
        self.currentExecutor = uploadExecutor
    }
    
    func findValue<T : CommandParameter>(for key: String) -> T? {
        return Application.processParameters.first(where: {$0.parameter == key}) as? T
    }
    
    fileprivate func queryAccountIfNeeded() {
        let userName: DoubleDashComplexParameter? = self.findValue(for: InputParameter.username.name)
        let password: DoubleDashComplexParameter? = self.findValue(for: InputParameter.password.name)
        if userName == nil {
            Console.readInput(message: "Enter your AppStore Connect account: ", readCallback: { (value) in
                if let value = value {
                    Application.processParameters.append(DoubleDashComplexParameter.init(parameter: InputParameter.username.name, composition: value))
                } else {
                    Console.log(message: "AppStore Connect account not informed, exiting...")
                    application.interrupt()
                }
            })
        }
        if password == nil {
            Console.readInputSecure(message: "Enter your AppStore Connect account password: ", readCallback: { (value) in
                if let value = value {
                    Application.processParameters.append(DoubleDashComplexParameter.init(parameter: InputParameter.password.name, composition: value))
                } else {
                    Console.log(message: "AppStore Connect account password not informed, exiting...")
                    application.interrupt()
                }
            })
        }
    }
}

extension CannonDistribute: ExecutorCompletionProtocol {
    func executorDidFinishWithSuccess(_ executor: ExecutorProtocol) {
        switch executor {
        case is ArchiveExecutor: self.archiveDidFinishWithSuccess()
        case is ExportExecutor: self.exportExecutorDidFinishWithSuccess()
        case is UploadExecutor: self.uploadExecutorDidFinishWithSuccess()
        case is CannonPreBuild: self.preBuildCommandExecutorDidFinishWithSuccess()
        default: break
        }
    }
    
    func executor(_ executor: ExecutorProtocol, didFailWithErrorCode code: Int) {
        switch executor {
        case is ArchiveExecutor: self.archiveDidFailWithStatusCode(code)
        case is ExportExecutor: self.exportExecutorDidFinishWithFailCode(code)
        case is UploadExecutor: self.uploadExecutorDidFailWithErrorCode(code)
        case is CannonPreBuild: self.preBuildCommandExecutorDidFailWithErrorCode(code)
        default: break
        }
    }
    
    func archiveDidFinishWithSuccess() {
        application.sourceCodeManager.deleteSourceCode()
        
        Console.log(message: "Archive finished with success")
        
        self.executeExport()
    }
    
    func archiveDidFailWithStatusCode(_ code: Int) {
        application.sourceCodeManager.deleteSourceCode()
        
        Console.log(message: "Archive failed with status code: \(code)")
        Console.log(message: "See logs at: \(ArchiveTool.Values.archiveLogPath)")
        
        application.interrupt()
    }

    @objc func exportExecutorDidFinishWithSuccess() {
        Console.log(message: "Export finished with success")
        
        self.executeUpload()
    }
    
    func exportExecutorDidFinishWithFailCode(_ code: Int) {
        Console.log(message: "Export failed with status code: \(code)")
        Console.log(message: "See logs at: \(ExportTool.Values.exportLogPath)")
        
        application.interrupt()
    }

    func uploadExecutorDidFinishWithSuccess() {
        Console.log(message: "Upload finished with success")
        
        application.interrupt()
    }
    
    func uploadExecutorDidFailWithErrorCode(_ code: Int) {
        Console.log(message: "Upload failed with status code: \(code)")
        Console.log(message: "See logs at: \(ExportTool.Values.exportLogPath)")
        
        application.interrupt()
    }
    
    func preBuildCommandExecutorDidFinishWithSuccess() {
        Console.log(message: "Pre-build finished with success")
        
        self.executeArchive()
    }
    
    func preBuildCommandExecutorDidFailWithErrorCode(_ code: Int) {
        Console.log(message: "Pre-build failed with status code: \(code)")
        
        application.interrupt()
    }
}
