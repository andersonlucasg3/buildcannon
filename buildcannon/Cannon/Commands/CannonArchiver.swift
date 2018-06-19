//
//  CannonArchiver.swift
//  buildcannon
//
//  Created by Anderson Lucas C. Ramos on 19/06/18.
//  Copyright © 2018 InsaniTech. All rights reserved.
//

import Foundation

class CannonArchiver: ExecutorProtocol {
    fileprivate var currentExecutor: ExecutorProtocol!
    
    weak var delegate: ExecutorCompletionProtocol?
    
    required init() {
        
    }
    
    func execute() {
        self.executeArchive()
    }
    
    func cancel() {
        self.currentExecutor.cancel()
    }
    
    fileprivate func executeArchive() {
        Console.log(message: "Starting archive at path: \(baseTempDir)")
        
        let archiveExecutor = ArchiveExecutor.init(project: self.findValue(for: Parameter.projectFile.name)!,
                                                   scheme: self.findValue(for: Parameter.scheme.name)!)
        archiveExecutor.delegate = self
        archiveExecutor.execute()
        self.currentExecutor = archiveExecutor
    }
    
    fileprivate func executeExport() {
        Console.log(message: "Starting export at path: \(baseTempDir)")
        
        let exportExecutor = ExportExecutor.init(archivePath: self.findValue(for: Parameter.archivePath.name),
                                                 teamId: self.findValue(for: Parameter.teamId.name)!,
                                                 bundleIdentifier: self.findValue(for: Parameter.bundleIdentifier.name)!,
                                                 provisioningProfileName: self.findValue(for: Parameter.provisioningProfile.name)!)
        exportExecutor.delegate = self
        exportExecutor.execute()
        self.currentExecutor = exportExecutor
    }
    
    fileprivate func executeUpload() {
        Console.log(message: "Starting upload of IPA at path: \(ExportTool.Values.exportPath)")
        
        self.queryAccountIfNeeded()
        
        let ipaPathParameter: DoubleDashComplexParameter? = self.findValue(for: Parameter.ipaPath.name)
        let scheme: DoubleDashComplexParameter = self.findValue(for: Parameter.scheme.name)!
        let ipaPath: String = ipaPathParameter?.composition ?? baseTempDir + "/\(scheme.composition).ipa"
        
        let uploadExecutor = UploadExecutor.init(ipaPath: ipaPath,
                                                 userName: self.findValue(for: Parameter.username.name)!,
                                                 password: self.findValue(for: Parameter.password.name)!)
        uploadExecutor.delegate = self
        uploadExecutor.execute()
        self.currentExecutor = uploadExecutor
    }
    
    fileprivate func findValue<T : CommandParameter>(for key: String) -> T? {
        return Application.processParameters.first(where: {$0.parameter == key}) as? T
    }
    
    fileprivate func queryAccountIfNeeded() {
        let userName: DoubleDashComplexParameter? = self.findValue(for: Parameter.username.name)
        let password: DoubleDashComplexParameter? = self.findValue(for: Parameter.password.name)
        if userName == nil {
            Console.readInput(message: "Enter your AppStore Connect account: ", readCallback: { (value) in
                if let value = value {
                    Application.processParameters.append(DoubleDashComplexParameter.init(parameter: Parameter.username.name, composition: value))
                } else {
                    Console.log(message: "AppStore Connect account not informed, exiting...")
                    application.interrupt()
                }
            })
        }
        if password == nil {
            Console.readInputSecure(message: "Enter your AppStore Connect account password: ", readCallback: { (value) in
                if let value = value {
                    Application.processParameters.append(DoubleDashComplexParameter.init(parameter: Parameter.password.name, composition: value))
                } else {
                    Console.log(message: "AppStore Connect account password not informed, exiting...")
                    application.interrupt()
                }
            })
        }
    }
}

extension CannonArchiver: ExecutorCompletionProtocol {
    func executorDidFinishWithSuccess(_ executor: ExecutorProtocol) {
        switch executor {
        case is ArchiveExecutor: self.archiveDidFinishWithSuccess()
        case is ExportExecutor: self.exportExecutorDidFinishWithSuccess()
        case is UploadExecutor: self.uploadExecutorDidFinishWithSuccess()
        default: break
        }
    }
    
    func executor(_ executor: ExecutorProtocol, didFailWithErrorCode code: Int) {
        switch executor {
        case is ArchiveExecutor: self.archiveDidFailWithStatusCode(code)
        case is ExportExecutor: self.exportExecutorDidFinishWithFailCode(code)
        case is UploadExecutor: self.uploadExecutorDidFailWithErrorCode(code)
        default: break
        }
    }
    
    func archiveDidFinishWithSuccess() {
        Console.log(message: "Archive finished with success")
        self.executeExport()
    }
    
    func archiveDidFailWithStatusCode(_ code: Int) {
        Console.log(message: "Archive failed with status code: \(code)")
        Console.log(message: "See logs at: \(ArchiveTool.Values.archiveLogPath)")
        application.interrupt()
    }

    func exportExecutorDidFinishWithSuccess() {
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
}
