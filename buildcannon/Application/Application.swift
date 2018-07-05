//
//  Main.swift
//  buildcannon
//
//  Created by Anderson Lucas C. Ramos on 14/06/18.
//  Copyright © 2018 InsaniTech. All rights reserved.
//

import Foundation

class Application {
    fileprivate(set) static var isVerbose = false
    fileprivate(set) static var isXcprettyInstalled = false
    
    static var processParameters: [CommandParameter] = Array<CommandParameter>.fromArgs()
    
    fileprivate var menu: ActionMenu!
    fileprivate var currentExecutor: ExecutorProtocol!
    
    fileprivate lazy var checker = ParametersChecker.init(parameters: Application.processParameters)
    
    init() {
        self.menu = self.createMenu()
    }
    
    deinit {
        Console.closeLog()
    }
    
    static func execute(_ block: @escaping os_block_t) {
        DispatchQueue.main.async(execute: block)
    }
    
    func start() {
        Application.execute { [unowned self] in
            #if DEBUG
            self.logDebugThings()
            #endif
            self.createDirectories()
            self.setupConfigurations {
                guard !self.checker.checkHelp() else {
                    self.menu.draw()
                    self.interrupt()
                    return
                }
                guard !self.checker.checkVersion() else {
                    Version.printVersion()
                    self.interrupt()
                    return
                }
                
                self.startInitialProcess()
            }
        }
        
        dispatchMain()
    }
    
    func interrupt() {
        self.currentExecutor?.cancel()
        exit(0)
    }
    
    fileprivate func startInitialProcess() {
        #if DEBUG
        Console.log(message: "\(Application.processParameters)")
        #endif
        Version.printVersion()
        if let parameter = Application.processParameters.first, let config = CannonParameter.get(command: parameter) as? CannonParameter {
            let executor = config.executorType.init()
            executor.delegate = self
            executor.execute()
            self.currentExecutor = executor
        } else {
            self.menu.draw()
            self.interrupt()
        }
    }
    
    fileprivate func logDebugThings() {
        Console.log(message: "Executing program with command: \(ProcessInfo.processInfo.arguments.joined(separator: " "))")
    }
    
    fileprivate func createMenu() -> ActionMenu {
        let options = [
            ActionMenuOption.init(command: "create", detail: "Creates the default.cannon file with basic configurations.", action: {}),
            ActionMenuOption.init(command: "distribute", detail: "Start the archive, export, upload flow to distribute an IPA.", action: {}),
            ActionMenuOption.init(command: "--\(Parameter.projectFile.name) \"[projName].[xcworkspace|xcodeproj]\"", detail: "Provide a proj.xcodeproj or a space.xcworkspace to build.", action: {}),
            ActionMenuOption.init(command: "--\(Parameter.scheme.name) \"[scheme name]\"", detail: "Provide a scheme name to build.", action: {}),
            ActionMenuOption.init(command: "--\(Parameter.configuration.name) \"[configuration name]\"", detail: "Provide a build configuration to build.", action: {}),
            ActionMenuOption.init(command: "--\(Parameter.target.name) \"[target name]\"", detail: "Provide a target to build.", action: {}),
            ActionMenuOption.init(command: "--\(Parameter.teamId.name) [12TEAM43ID]", detail: "Provide a Team ID to publish on.", action: {}),
            ActionMenuOption.init(command: "--\(Parameter.bundleIdentifier.name) [com.yourcompany.app]", detail: "Provide a bundle identifier to build.", action: {}),
            ActionMenuOption.init(command: "--\(Parameter.provisioningProfile.name) \"[your provisioning profile name]\"", detail: "Provide a provisioning profile name to build.", action: {}),
            ActionMenuOption.init(command: "--\(Parameter.verbose.name)", detail: "Logs all content into the console.", action: {}),
            ActionMenuOption.init(command: "--\(Parameter.help.name)", detail: "Shows this menu with public parameters.", action: {}),
            ActionMenuOption.init(command: "--\(Parameter.archivePath.name) \"[/path/to/archive.xcarchive]\"", detail: "If --exportOnly is specified this parameter MUST be informed.", action: {}),
            ActionMenuOption.init(command: "--\(Parameter.ipaPath.name) \"[/path/to/ipa.ipa]\"", detail: "If --uploadOnly is specified this parameter MUST be informed.", action: {}),
            ActionMenuOption.init(command: "--\(Parameter.username.name) account_name@domain.com", detail: "Specifies the AppStore Connect account (email).", action: {}),
            ActionMenuOption.init(command: "--\(Parameter.password.name) **********", detail: "Specifies the AppStore Connect account password.", action: {}),
            ActionMenuOption.init(command: "--\(Parameter.version.name)", detail: "Prints the version of the installed buildcannon binary.", action: {})
        ]
        return ActionMenu.init(description: "Usage: ", options: options)
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

    fileprivate func removeCacheDir() {
        do {
            try FileManager.default.removeItem(atPath: baseTempDir)
        } catch let error {
            Console.log(message: "Tried to delete build path but failed: \(baseTempDir)")
            Console.log(message: "Error: \(error.localizedDescription)")
        }
    }
    
    func copySourceCode() {
        do {
            try FileManager.default.createDirectory(at: sourceCodeTempDir, withIntermediateDirectories: true, attributes: nil)
            let contents = try FileManager.default.contentsOfDirectory(atPath: FileManager.default.currentDirectoryPath)
                .filter({!$0.hasPrefix(".")})
                .map({
                    (from: URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent($0),
                       to: sourceCodeTempDir.appendingPathComponent($0))
                })
            try contents.forEach({
                #if DEBUG
                Console.log(message: "Copying file from \"\($0.from.path)\" to \"\($0.to.path)\"")
                #endif
                try FileManager.default.copyItem(at: $0.from, to: $0.to)
            })
        } catch let error {
            Console.log(message: "Coudn't copy source contents, interrupting...")
            Console.log(message: "Error: \(error.localizedDescription)")
            self.deleteSourceCode()
            application.interrupt()
        }
    }
    
    func deleteSourceCode() {
        try? FileManager.default.removeItem(at: sourceCodeTempDir)
    }
}

extension Application: ExecutorCompletionProtocol {
    func executorDidFinishWithSuccess(_ executor: ExecutorProtocol) {
        Console.log(message: "buildcannon finished with success")
        self.removeCacheDir()
        application.interrupt()
    }
    
    func executor(_ executor: ExecutorProtocol, didFailWithErrorCode code: Int) {
        Console.log(message: "buildcannon failed with status code: \(code)")
        Console.log(message: "See logs at: \(baseTempDir)")
        application.interrupt()
    }
}
