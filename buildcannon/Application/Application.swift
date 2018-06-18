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
    fileprivate(set) static var isExportOnly = false
    fileprivate(set) static var isUploadOnly = false
    
    fileprivate var isAlive = true
    
    fileprivate var processParameters: [CommandParameter] = Array<CommandParameter>.fromArgs()
    
    fileprivate var menu: ActionMenu!
    fileprivate var archiveExecutor: ArchiveExecutor!
    fileprivate var exportExecutor: ExportExecutor!
    fileprivate var uploadExecutor: UploadExecutor!
    
    fileprivate lazy var checker = CommandParametersChecker.init(parameters: self.processParameters)
    
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
                guard !self.checker.checkHelp() && self.checker.checkParameters() else {
                    self.menu.draw()
                    application.interrupt()
                    return
                }
                
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
        self.archiveExecutor?.cancel()
    }
    
    fileprivate func startInitialProcess() {
        if Application.isExportOnly {
            self.executeExport()
        } else if Application.isUploadOnly {
            self.executeUpload()
        } else {
            self.executeArchive()
        }
    }
    
    fileprivate func logDebugThings() {
        Console.log(message: "Executing program with command: \(ProcessInfo.processInfo.arguments.joined(separator: " "))")
    }
    
    fileprivate func createMenu() -> ActionMenu {
        let options = [
            ActionMenuOption.init(command: "--\(Parameters.projectFile.name) \"[projName].[xcworkspace|xcodeproj]\"", detail: "Provide a proj.xcodeproj or a space.xcworkspace to build.", action: {}),
            ActionMenuOption.init(command: "--\(Parameters.scheme.name) \"[scheme name]\"", detail: "Provide a scheme name to build.", action: {}),
            ActionMenuOption.init(command: "--\(Parameters.teamId.name) [12TEAM43ID]", detail: "Provide a Team ID to publish on.", action: {}),
            ActionMenuOption.init(command: "--\(Parameters.bundleIdentifier.name) [com.yourcompany.app]", detail: "Provide a bundle identifier to build.", action: {}),
            ActionMenuOption.init(command: "--\(Parameters.provisioningProfile.name) \"[your provisioning profile name]\"", detail: "Provide a provisioning profile name to build.", action: {}),
            ActionMenuOption.init(command: "--\(Parameters.verbose.name)", detail: "Logs all content into the console.", action: {}),
            ActionMenuOption.init(command: "--\(Parameters.help.name)", detail: "Shows this menu with public parameters.", action: {}),
            ActionMenuOption.init(command: "--\(Parameters.exportOnly.name)", detail: "Tells the buildcannon to execute only the IPA export.", action: {}),
            ActionMenuOption.init(command: "--\(Parameters.archivePath.name) \"[/path/to/archive.xcarchive]\"", detail: "If --exportOnly is specified this parameter MUST be informed.", action: {}),
            ActionMenuOption.init(command: "--\(Parameters.uploadOnly.name)", detail: "Tells the buildcannon to execute only the upload of an IPA.", action: {}),
            ActionMenuOption.init(command: "--\(Parameters.ipaPath.name) \"[/path/to/ipa.ipa]\"", detail: "If --uploadOnly is specified this parameter MUST be informed.", action: {}),
            ActionMenuOption.init(command: "--\(Parameters.userName.name) account_name@domain.com", detail: "Specifies the AppStore Connect account (email).", action: {}),
            ActionMenuOption.init(command: "--\(Parameters.password.name) **********", detail: "Specifies the AppStore Connect account password.", action: {})
        ]
        return ActionMenu.init(description: "Usage: ", options: options)
    }
    
    fileprivate func findValue<T : CommandParameter>(for key: String) -> T? {
        return self.processParameters.first(where: {$0.parameter == key}) as? T
    }
    
    fileprivate func queryAccountIfNeeded() {
        let userName: DoubleDashComplexParameter? = self.findValue(for: Parameters.userName.name)
        let password: DoubleDashComplexParameter? = self.findValue(for: Parameters.password.name)
        if userName == nil {
            Console.readInput(message: "Enter your AppStore Connect account: ", readCallback: { [unowned self] (value) in
                if let value = value {
                    self.processParameters.append(DoubleDashComplexParameter.init(parameter: Parameters.userName.name, composition: value))
                } else {
                    Console.log(message: "AppStore Connect account not informed, exiting...")
                    application.interrupt()
                }
            })
        }
        if password == nil {
            Console.readInputSecure(message: "Enter your AppStore Connect account password: ", readCallback: { (value) in
                if let value = value {
                    self.processParameters.append(DoubleDashComplexParameter.init(parameter: Parameters.password.name, composition: value))
                } else {
                    Console.log(message: "AppStore Connect account password not informed, exiting...")
                    application.interrupt()
                }
            })
        }
    }
    
    fileprivate func executeArchive() {
        Console.log(message: "Starting archive at path: \(baseTempDir)")
        
        self.archiveExecutor = ArchiveExecutor.init(project: self.findValue(for: Parameters.projectFile.name)!,
                                                    scheme: self.findValue(for: Parameters.scheme.name)!)
        self.archiveExecutor.delegate = self
        self.archiveExecutor.execute()
    }
    
    fileprivate func executeExport() {
        Console.log(message: "Starting export at path: \(baseTempDir)")
        
        self.exportExecutor = ExportExecutor.init(archivePath: self.findValue(for: Parameters.archivePath.name),
                                                  teamId: self.findValue(for: Parameters.teamId.name)!,
                                                  bundleIdentifier: self.findValue(for: Parameters.bundleIdentifier.name)!,
                                                  provisioningProfileName: self.findValue(for: Parameters.provisioningProfile.name)!)
        self.exportExecutor.delegate = self
        self.exportExecutor.execute()
    }
    
    fileprivate func executeUpload() {
        Console.log(message: "Starting upload of IPA at path: \(ExportTool.Values.exportPath)")
        
        self.queryAccountIfNeeded()
        
        let ipaPathParameter: DoubleDashComplexParameter? = self.findValue(for: Parameters.ipaPath.name)
        let scheme: DoubleDashComplexParameter = self.findValue(for: Parameters.scheme.name)!
        let ipaPath: String = ipaPathParameter?.composition ?? baseTempDir + "/\(scheme.composition).ipa"
        
        self.uploadExecutor = UploadExecutor.init(ipaPath: ipaPath,
                                                  userName: self.findValue(for: Parameters.userName.name)!,
                                                  password: self.findValue(for: Parameters.password.name)!)
        self.uploadExecutor.delegate = self
        self.uploadExecutor.execute()
    }
    
    fileprivate func setupConfigurations(completion: @escaping os_block_t) {
        self.checker.checkXcprettyInstalled { (exists) in
            Application.isXcprettyInstalled = exists
            Application.isVerbose = self.checker.checkVerbose()
            Application.isExportOnly = self.checker.checkExportOnly()
            Application.isUploadOnly = self.checker.checkUploadOnly()
            
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
        self.archiveExecutor = nil
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
        self.exportExecutor = nil
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
