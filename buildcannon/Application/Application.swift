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
    
    static var processParameters: [CommandParameter] = Array<CommandParameter>.fromArgs()
    
    fileprivate var isAlive = true
    
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
                guard !self.checker.checkHelp() else {
                    self.menu.draw()
                    self.interrupt()
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
        self.currentExecutor?.cancel()
    }
    
    fileprivate func startInitialProcess() {
        #if DEBUG
        Console.log(message: "\(Application.processParameters)")
        #endif
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
            ActionMenuOption.init(command: "--\(Parameter.password.name) **********", detail: "Specifies the AppStore Connect account password.", action: {})
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
}

extension Application: ExecutorCompletionProtocol {
    func executorDidFinishWithSuccess(_ executor: ExecutorProtocol) {
        Console.log(message: "buildcannon finished with success")
        application.interrupt()
    }
    
    func executor(_ executor: ExecutorProtocol, didFailWithErrorCode code: Int) {
        Console.log(message: "buildcannon failed with status code: \(code)")
        Console.log(message: "See logs at: \(baseTempDir)")
        application.interrupt()
    }
}
