//
//  main.swift
//  buildtool
//
//  Created by Anderson Lucas C. Ramos on 13/06/18.
//  Copyright © 2018 Anderson Lucas C. Ramos. All rights reserved.
//

import Foundation
import Dispatch

class Main {
    fileprivate let processParameters: [CommandParameter]
    
    fileprivate var menu: ActionMenu!
    fileprivate var archiveExecutor: ArchiveExecutor!
    
    fileprivate lazy var checker = CommandParametersChecker.init(parameters: self.processParameters)
    
    init() {
        self.processParameters = Array<CommandParameter>.fromArgs()
        self.menu = self.createMenu()
    }
    
    deinit {
        Logger.closeLog()
    }
    
    func start() {
        guard !self.checker.checkHelp() && self.checker.checkParameters() else {
            self.menu.draw()
            return
        }
        
        self.createDirectories()
        self.executeArchive()
        dispatchMain()
    }
   
    func interrupt() {
        self.archiveExecutor?.cancel()
    }
    
    fileprivate func createMenu() -> ActionMenu {
        let options = [
            ActionMenuOption.init(command: "--\(Parameters.projectFile.name)", detail: "Provide a proj.xcodeproj or a space.xcworkspace to build.", action: {}),
            ActionMenuOption.init(command: "--\(Parameters.scheme.name)", detail: "Provide a scheme name to build.", action: {}),
            ActionMenuOption.init(command: "--\(Parameters.teamId.name)", detail: "Provide a Team ID to publish on.", action: {}),
            ActionMenuOption.init(command: "--\(Parameters.bundleIdentifier.name)", detail: "Provide a bundle identifier to build.", action: {}),
            ActionMenuOption.init(command: "--\(Parameters.provisioningProfile.name)", detail: "Provide a provisioning profile name to build.", action: {}),
            ActionMenuOption.init(command: "--\(Parameters.verbose.name)", detail: "Logs all content into the console.", action: {}),
            ActionMenuOption.init(command: "--\(Parameters.help.name)", detail: "Shows this menu with public parameters.", action: {})
        ]
        return ActionMenu.init(description: "Usage: ", options: options)
    }
    
    fileprivate func executeArchive() {
        let project = self.processParameters.first(where: {$0.parameter == Parameters.projectFile.name}) as! DoubleDashComplexParameter
        let scheme = self.processParameters.first(where: {$0.parameter == Parameters.scheme.name}) as! DoubleDashComplexParameter
        
        self.archiveExecutor = ArchiveExecutor.init(project: project, scheme: scheme)
        self.archiveExecutor.execute()
    }
    
    fileprivate func createDirectories() {
        if !FileManager.default.fileExists(atPath: baseTempDir) {
            try! FileManager.default.createDirectory(atPath: baseTempDir, withIntermediateDirectories: true, attributes: nil)
        }
        Logger.log(message: "Building at temp path: \(baseTempDir)")
    }
}

let main = Main.init()
signal(SIGINT, SIG_IGN)
let source = DispatchSource.makeSignalSource(signal: SIGINT, queue: .main)
source.setEventHandler {
    main.interrupt()
    exit(0)
}
source.resume()
main.start()
