//
//  Main.swift
//  buildtool
//
//  Created by Anderson Lucas C. Ramos on 14/06/18.
//  Copyright © 2018 InsaniTech. All rights reserved.
//

import Foundation

class Application {
    fileprivate(set) static var isVerbose = false
    fileprivate(set) static var isXcprettyInstalled = false
    fileprivate(set) static var isExportOnly = false
    
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
    
    func start() {
        DispatchQueue.main.async {
            #if DEBUG
            self.logDebugThings()
            #endif
            self.createDirectories()
            self.setupConfigurations()
            
            guard !self.checker.checkHelp() && self.checker.checkParameters() else {
                self.menu.draw()
                exit(0)
            }
            
            self.startInitialProcess()
        }
        dispatchMain()
    }
    
    func interrupt() {
        self.archiveExecutor?.cancel()
    }
    
    fileprivate func startInitialProcess() {
        if Application.isExportOnly {
            self.executeExport()
        } else {
            self.executeArchive()
        }
    }
    
    fileprivate func logDebugThings() {
        Console.log(message: "Executing program with command: \(ProcessInfo.processInfo.arguments.joined(separator: " "))")
    }
    
    fileprivate func createMenu() -> ActionMenu {
        let options = [
            ActionMenuOption.init(command: "--\(Parameters.projectFile.name)", detail: "Provide a proj.xcodeproj or a space.xcworkspace to build.", action: {}),
            ActionMenuOption.init(command: "--\(Parameters.scheme.name)", detail: "Provide a scheme name to build.", action: {}),
            ActionMenuOption.init(command: "--\(Parameters.teamId.name)", detail: "Provide a Team ID to publish on.", action: {}),
            ActionMenuOption.init(command: "--\(Parameters.bundleIdentifier.name)", detail: "Provide a bundle identifier to build.", action: {}),
            ActionMenuOption.init(command: "--\(Parameters.provisioningProfile.name)", detail: "Provide a provisioning profile name to build.", action: {}),
            ActionMenuOption.init(command: "--\(Parameters.verbose.name)", detail: "Logs all content into the console.", action: {}),
            ActionMenuOption.init(command: "--\(Parameters.help.name)", detail: "Shows this menu with public parameters.", action: {}),
            ActionMenuOption.init(command: "--\(Parameters.exportOnly.name)", detail: "Tells the buildtool to execute only the export IPA part.", action: {}),
            ActionMenuOption.init(command: "--\(Parameters.archivePath.name)", detail: "If --exportOnly is specified this parameter MUST be informed.", action: {}),
            ActionMenuOption.init(command: "--\(Parameters.userName.name)", detail: "Specifies the AppStore Connect account (email).", action: {}),
            ActionMenuOption.init(command: "--\(Parameters.password.name)", detail: "Specifies the AppStore Connect account password.", action: {})
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
            Console.readInput(message: "Enter your AppStore Connect account: ") { [unowned self] (value) in
                if let value = value {
                    self.processParameters.append(DoubleDashComplexParameter.init(parameter: Parameters.userName.name, composition: value))
                } else {
                    Console.log(message: "AppStore Connect account not informed, exiting...")
                    exit(0)
                }
            }
        }
        if password == nil {
            Console.readInput(message: "Enter your AppStore Connect account password: ") { (value) in
                if let value = value {
                    self.processParameters.append(DoubleDashComplexParameter.init(parameter: Parameters.password.name, composition: value))
                } else {
                    Console.log(message: "AppStore Connect account password not informed, exiting...")
                }
            }
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
        
        self.uploadExecutor = UploadExecutor.init(userName: self.findValue(for: Parameters.userName.name)!,
                                                  password: self.findValue(for: Parameters.password.name)!)
        self.uploadExecutor.delegate = self
        self.uploadExecutor.execute()
    }
    
    fileprivate func setupConfigurations() {
        Application.isXcprettyInstalled = self.checker.checkXcprettyInstalled()
        Application.isVerbose = self.checker.checkVerbose()
        Application.isExportOnly = self.checker.checkExportOnly()
        
        if !Application.isXcprettyInstalled {
            Console.log(message: "Please install `xcpretty` with `gem install xcpretty`. Tried to install but failed.")
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
        exit(0)
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
        exit(0)
    }
}

extension Application: UploadExecutorProtocol {
    func uploadExecutorDidFinishWithSuccess() {
        Console.log(message: "Upload finished with success")
        exit(0)
    }
    
    func uploadExecutorDidFailWithErrorCode(_ code: Int) {
        Console.log(message: "Upload failed with status code: \(code)")
        Console.log(message: "See logs at: \(ExportTool.Values.exportLogPath)")
        exit(0)
    }
}
