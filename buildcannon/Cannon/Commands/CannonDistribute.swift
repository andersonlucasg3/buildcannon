//
//  CannonDistribute.swift
//  buildcannon
//
//  Created by Anderson Lucas C. Ramos on 19/06/18.
//  Copyright © 2018 InsaniTech. All rights reserved.
//

import Foundation

class CannonDistribute: ExecutorProtocol, ExecutorCompletionProtocol {
    let separator = "="
    var currentExecutor: ExecutorProtocol!
    
    fileprivate(set) var targetList: [String]!
    var currentTarget: String { return self.targetList?.first ?? "default" }
    
    weak var delegate: ExecutorCompletionProtocol?
    
    required init() { }
    
    func execute() {
        application.sourceCodeManager.copySourceCode()
        
        self.targetList = DistributeTargetsProcessor.init(Application.processParameters).process()
        
        self.executeNextTarget()
    }
    
    func validateRequiredParameters(dependency: [InputParameter]?) -> Bool {
        Console.log(message: "Parameters: \(Application.processParameters.map({$0.parameter}).joined(separator: ","))")
        if let dependencies = dependency {
            for dep in dependencies {
                if !Application.processParameters.contains(where: {$0.parameter.contains(dep.name)}) {
                    Console.log(message: "Required parameter not informed: \(dep.name)")
                    return false
                }
            }
        }
        return true
    }
    
    fileprivate func executeNextTarget() {
        Console.log(message: "Cannon project \(self.currentTarget).cannon will be used.")
        
        let fileLoader = CannonFileLoader.init()
        if let file = fileLoader.load(target: self.currentTarget) {
            fileLoader.assign(file: file, processParameters: &Application.processParameters)
            self.executePreBuild(file: file)
        } else {
            Console.log(message: "Cannon project file not exists.")
            self.delegate?.executor(self, didFailWithErrorCode: -1)
        }
    }
    
    func dequeueAndExecuteNextTargetIfNeeded(exitCode: Int) {
        self.targetList?.removeFirst()
        if self.targetList?.count ?? 0 > 0 {
            self.executeNextTarget()
        } else {
            application.interrupt(code: exitCode)
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
        let scheme: DoubleDashComplexParameter? = self.findValue(for: InputParameter.Project.scheme.name)
        let ipaPathParameter: DoubleDashComplexParameter? = self.findValue(for: InputParameter.Output.ipaPath.name)
        return ipaPathParameter?.composition ?? baseTempDir + "/\(scheme?.composition ?? "app").ipa"
    }
    
    fileprivate func startPreBuildCommandExecutor(_ preBuild: [String]) {
        Console.log(message: "Starting pre-build commands...")
        
        let executor = CannonPreBuild.init(preBuildCommands: preBuild)
        executor.delegate = self
        executor.execute()
        self.currentExecutor = executor
    }
    
    func executeArchive() {
        Console.log(message: "Starting archive at path: \(BuildcannonProcess.workingDir(wasSourceCopied: application.shouldCopyCode).path)")
        
        let archiveExecutor = ArchiveExecutor.init(project: self.findValue(for: InputParameter.Project.projectFile.name),
                                                   target: self.findValue(for: InputParameter.Project.target.name),
                                                   sdk: self.findValue(for: InputParameter.Project.sdk.name),
                                                   scheme: self.findValue(for: InputParameter.Project.scheme.name)!,
                                                   configuration: self.findValue(for: InputParameter.Project.configuration.name)!)
        archiveExecutor.delegate = self
        archiveExecutor.execute()
        self.currentExecutor = archiveExecutor
    }
    
    func executeExport() {
        Console.log(message: "Starting export at path: \(baseTempDir)")
        
        let sdk: DoubleDashComplexParameter? = self.findValue(for: InputParameter.Project.sdk.name)
        let tvosExport = (sdk?.composition ?? "").contains("appletvos")
        let exportExecutor = ExportExecutor.init(archivePath: self.findValue(for: InputParameter.Output.archivePath.name),
                                                 teamId: self.findValue(for: InputParameter.Project.teamId.name)!,
                                                 bundleIdentifier: self.findValue(for: InputParameter.Project.bundleIdentifier.name)!,
                                                 topShelfBundleIdentifier: self.findValue(for: InputParameter.Project.topShelfBundleIdentifier.name),
                                                 provisioningProfileName: self.findValue(for: InputParameter.Project.provisioningProfile.name)!,
                                                 topShelfProvisioningProfile: self.findValue(for: InputParameter.Project.topShelfProvisioningProfile.name),
                                                 exportMethod: self.findValue(for: InputParameter.Project.exportMethod.name),
                                                 tvosExport: tvosExport,
                                                 includeBitcode: tvosExport)
        exportExecutor.delegate = self
        exportExecutor.execute()
        self.currentExecutor = exportExecutor
    }
    
    func executeUpload() {
        Console.log(message: "Starting upload of IPA at path: \(ExportTool.Values.exportPath)")
        
        self.queryAccountIfNeeded()
        
        let uploadExecutor = UploadExecutor.init(ipaPath: self.getIpaPath(),
                                                 userName: self.findValue(for: InputParameter.Identity.username.name)!,
                                                 password: self.findValue(for: InputParameter.Identity.password.name)!)
        uploadExecutor.delegate = self
        uploadExecutor.execute()
        self.currentExecutor = uploadExecutor
    }
    
    func findValue<T : CommandParameter>(for key: String) -> T? {
        return Application.processParameters.first(where: {$0.parameter == key}) as? T
    }
    
    fileprivate func queryAccountIfNeeded() {
        let userName: DoubleDashComplexParameter? = self.findValue(for: InputParameter.Identity.username.name)
        let password: DoubleDashComplexParameter? = self.findValue(for: InputParameter.Identity.password.name)
        if userName == nil {
            Console.readInput(message: "Enter your AppStore Connect account: ", readCallback: { (value) in
                if let value = value {
                    Application.processParameters.append(DoubleDashComplexParameter.init(parameter: InputParameter.Identity.username.name, composition: value, separator: self.separator))
                } else {
                    Console.log(message: "AppStore Connect account not informed, exiting...")
                    application.interrupt(code: -1)
                }
            })
        }
        if password == nil {
            Console.readInputSecure(message: "Enter your AppStore Connect account password: ", readCallback: { (value) in
                if let value = value {
                    Application.processParameters.append(DoubleDashComplexParameter.init(parameter: InputParameter.Identity.password.name, composition: value, separator: self.separator))
                } else {
                    Console.log(message: "AppStore Connect account password not informed, exiting...")
                    application.interrupt(code: -1)
                }
            })
        }
    }

    // MARK: - ExecutorCompletionProtocol
    
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
    
    // MARK: - Pre build callbacks

    func preBuildCommandExecutorDidFinishWithSuccess() {
        Console.log(message: "Pre-build finished with success for target \(self.currentTarget)")
        
        self.executeArchive()
    }
    
    func preBuildCommandExecutorDidFailWithErrorCode(_ code: Int) {
        Console.log(message: "Pre-build failed with status code \(code) for target \(self.currentTarget)")
        
        application.interrupt(code: code)
    }
    
    // MARK: - Archive callbacks
    
    func archiveDidFinishWithSuccess() {
        application.sourceCodeManager.deleteSourceCode()
        
        Console.log(message: "Archive finished with success for target \(self.currentTarget)")
        
        self.executeExport()
    }
    
    func archiveDidFailWithStatusCode(_ code: Int) {
        application.sourceCodeManager.deleteSourceCode()
        
        Console.log(message: "Archive failed with status code \(code) for target \(self.currentTarget)")
        Console.log(message: "See logs at: \(ArchiveTool.Values.archiveLogPath)")
        
        self.dequeueAndExecuteNextTargetIfNeeded(exitCode: code)
    }
    
    // MARK: - Export callbacks
    
    @objc func exportExecutorDidFinishWithSuccess() {
        Console.log(message: "Export finished with success for target \(self.currentTarget)")
        
        self.executeUpload()
    }
    
    func exportExecutorDidFinishWithFailCode(_ code: Int) {
        Console.log(message: "Export failed with status code \(code) for target \(self.currentTarget)")
        Console.log(message: "See logs at: \(ExportTool.Values.exportLogPath)")
        
        self.dequeueAndExecuteNextTargetIfNeeded(exitCode: code)
    }
    
    // MARK: - Upload callbacks
    
    @objc func uploadExecutorDidFinishWithSuccess() {
        Console.log(message: "Upload finished with success for target \(self.currentTarget)")
        
        self.dequeueAndExecuteNextTargetIfNeeded(exitCode: 0)
    }
    
    func uploadExecutorDidFailWithErrorCode(_ code: Int) {
        Console.log(message: "Upload failed with status code \(code) for target \(self.currentTarget)")
        Console.log(message: "See logs at: \(UploadTool.Values.uploadLogPath)")
        
        self.dequeueAndExecuteNextTargetIfNeeded(exitCode: code)
    }
}
