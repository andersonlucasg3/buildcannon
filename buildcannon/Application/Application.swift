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
    
    static var processParameters: [CommandParameter] = Array<CommandParameter>.from(arguments: ProcessInfo.processInfo.arguments)
    
    fileprivate var menu: ActionMenu!
    fileprivate var currentExecutor: ExecutorProtocol!
    
    fileprivate lazy var checker = ParametersChecker.init(parameters: Application.processParameters)
    
    let sourceCodeManager = SourceCodeManager.init()
    
    init() {
        self.menu = AppMenu.createMenu()
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
            self.sourceCodeManager.createDirectories()
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
    
    func interrupt(code: Int) {
        self.currentExecutor?.cancel()
        exit(Int32(code))
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
}

extension Application: ExecutorCompletionProtocol {
    func executorDidFinishWithSuccess(_ executor: ExecutorProtocol) {
        Console.log(message: "buildcannon finished with success")
        self.sourceCodeManager.removeCacheDir()
        application.interrupt()
    }
    
    func executor(_ executor: ExecutorProtocol, didFailWithErrorCode code: Int) {
        Console.log(message: "buildcannon failed with status code: \(code)")
        Console.log(message: "See logs at: \(baseTempDir)")
        application.interrupt()
    }
}
