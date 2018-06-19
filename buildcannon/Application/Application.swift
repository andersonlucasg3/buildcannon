//
//  Main.swift
//  buildcannon
//
//  Created by Anderson Lucas C. Ramos on 14/06/18.
//  Copyright © 2018 InsaniTech. All rights reserved.
//

import Foundation

class Application {
    fileprivate static var executionQueue = Array<os_block_t>.init()
    
    fileprivate(set) static var isVerbose = false
    fileprivate(set) static var isXcprettyInstalled = false
    
    fileprivate var isAlive = true
    
    fileprivate var processParameters: [CommandParameter] = Array<CommandParameter>.fromArgs()
    
    fileprivate var menu: ActionMenu!
    fileprivate var currentExecutor: ExecutorProtocol!
    
    fileprivate lazy var checker = ParametersChecker.init(parameters: self.processParameters)
    
    init() {
        self.menu = self.createMenu()
    }
    
    deinit {
        Console.closeLog()
    }
    
    static func execute(_ block: @escaping os_block_t) {
        Synchronizator.synchronize({
            self.executionQueue.append(block)
        }, to: self)
    }
    
    func start() {
        Application.execute { [unowned self] in
            #if DEBUG
            self.logDebugThings()
            #endif
            self.createDirectories()
            self.setupConfigurations {
//                guard !self.checker.checkHelp() && self.checker.checkParameters(for: <#T##Parameter#>) else {
//                    self.menu.draw()
//                    application.interrupt()
//                    return
//                }
                
                self.startInitialProcess()
            }
        }
        
        repeat {
            Synchronizator.synchronize({
                if let block = Application.executionQueue.first {
                    block()
                    _ = Application.executionQueue.removeFirst()
                }
            }, to: self)
        } while self.isAlive
    }
    
    func interrupt() {
        self.isAlive = false
        self.currentExecutor?.cancel()
    }
    
    fileprivate func startInitialProcess() {
        
    }
    
    fileprivate func logDebugThings() {
        Console.log(message: "Executing program with command: \(ProcessInfo.processInfo.arguments.joined(separator: " "))")
    }
    
    fileprivate func createMenu() -> ActionMenu {
        let options = [
            ActionMenuOption.init(command: "create", detail: "Creates the default.cannon file with basic configurations.", action: {}),
            ActionMenuOption.init(command: "--\(Parameter.projectFile.name) \"[projName].[xcworkspace|xcodeproj]\"", detail: "Provide a proj.xcodeproj or a space.xcworkspace to build.", action: {}),
            ActionMenuOption.init(command: "--\(Parameter.scheme.name) \"[scheme name]\"", detail: "Provide a scheme name to build.", action: {}),
            ActionMenuOption.init(command: "--\(Parameter.teamId.name) [12TEAM43ID]", detail: "Provide a Team ID to publish on.", action: {}),
            ActionMenuOption.init(command: "--\(Parameter.bundleIdentifier.name) [com.yourcompany.app]", detail: "Provide a bundle identifier to build.", action: {}),
            ActionMenuOption.init(command: "--\(Parameter.provisioningProfile.name) \"[your provisioning profile name]\"", detail: "Provide a provisioning profile name to build.", action: {}),
            ActionMenuOption.init(command: "--\(Parameter.verbose.name)", detail: "Logs all content into the console.", action: {}),
            ActionMenuOption.init(command: "--\(Parameter.help.name)", detail: "Shows this menu with public parameters.", action: {}),
            ActionMenuOption.init(command: "--\(Parameter.archivePath.name) \"[/path/to/archive.xcarchive]\"", detail: "If --exportOnly is specified this parameter MUST be informed.", action: {}),
            ActionMenuOption.init(command: "--\(Parameter.ipaPath.name) \"[/path/to/ipa.ipa]\"", detail: "If --uploadOnly is specified this parameter MUST be informed.", action: {}),
            ActionMenuOption.init(command: "--\(Parameter.username.name) account_name@domain.com", detail: "Specifies the AppStore Connect account (email).", action: {}),
            ActionMenuOption.init(command: "--\(Parameter.password.name) **********", detail: "Specifies the AppStore Connect account password.", action: {})
        ]
        return ActionMenu.init(description: "Usage: ", options: options)
    }
    
    fileprivate func findValue<T : CommandParameter>(for key: String) -> T? {
        return self.processParameters.first(where: {$0.parameter == key}) as? T
    }
    
    fileprivate func queryAccountIfNeeded() {
        let userName: DoubleDashComplexParameter? = self.findValue(for: Parameter.username.name)
        let password: DoubleDashComplexParameter? = self.findValue(for: Parameter.password.name)
        if userName == nil {
            Console.readInput(message: "Enter your AppStore Connect account: ", readCallback: { [unowned self] (value) in
                if let value = value {
                    self.processParameters.append(DoubleDashComplexParameter.init(parameter: Parameter.username.name, composition: value))
                } else {
                    Console.log(message: "AppStore Connect account not informed, exiting...")
                    application.interrupt()
                }
            })
        }
        if password == nil {
            Console.readInputSecure(message: "Enter your AppStore Connect account password: ", readCallback: { (value) in
                if let value = value {
                    self.processParameters.append(DoubleDashComplexParameter.init(parameter: Parameter.password.name, composition: value))
                } else {
                    Console.log(message: "AppStore Connect account password not informed, exiting...")
                    application.interrupt()
                }
            })
        }
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
    
    fileprivate func setupConfigurations(completion: @escaping os_block_t) {
        self.checker.checkXcprettyInstalled { (exists) in
            Application.isXcprettyInstalled = exists
            Application.isVerbose = self.checker.checkVerbose()
            
            if !Application.isXcprettyInstalled {
                Console.log(message: "Please install `xcpretty` with `gem install xcpretty`. Tried to install but failed.")
            }
            
            Application.execute(completion)
        }
    }
    
    fileprivate func createDirectories() {
        if !FileManager.default.fileExists(atPath: baseTempDir) {
            try! FileManager.default.createDirectory(atPath: baseTempDir, withIntermediateDirectories: true, attributes: nil)
        }
    }
}

extension Application: ArchiveExecutorProtocol {
    func archiveDidFinishWithSuccess() {
        Console.log(message: "Archive finished with success")
        self.executeExport()
    }
    
    func archiveDidFailWithStatusCode(_ code: Int) {
        Console.log(message: "Archive failed with status code: \(code)")
        Console.log(message: "See logs at: \(ArchiveTool.Values.archiveLogPath)")
        application.interrupt()
    }
}

extension Application: ExportExecutorProtocol {
    func exportExecutorDidFinishWithSuccess() {
        Console.log(message: "Export finished with success")
        self.executeUpload()
    }
    
    func exportExecutorDidFinishWithFailCode(_ code: Int) {
        Console.log(message: "Export failed with status code: \(code)")
        Console.log(message: "See logs at: \(ExportTool.Values.exportLogPath)")
        application.interrupt()
    }
}

extension Application: UploadExecutorProtocol {
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
