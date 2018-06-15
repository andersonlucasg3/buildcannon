//
//  Main.swift
//  buildtool
//
//  Created by Anderson Lucas C. Ramos on 14/06/18.
//  Copyright © 2018 Anderson Lucas C. Ramos. All rights reserved.
//

import Foundation

class Application {
    fileprivate(set) static var isVerbose = false
    
    fileprivate let processParameters: [CommandParameter] = Array<CommandParameter>.fromArgs()
    
    fileprivate var menu: ActionMenu!
    fileprivate var archiveExecutor: ArchiveExecutor!
    
    fileprivate lazy var checker = CommandParametersChecker.init(parameters: self.processParameters)
    
    init() {
        self.menu = self.createMenu()
    }
    
    deinit {
        Logger.closeLog()
    }
    
    func start() {
        if !self.checker.checkXcprettyInstalled() {
            Logger.log(message: "Please install `xcpretty`. Tried to install but failed.")
            return
        }
        
        guard !self.checker.checkHelp() && self.checker.checkParameters() else {
            self.menu.draw()
            return
        }
        Application.isVerbose = self.checker.checkVerbose()
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
        self.archiveExecutor.delegate = self
        self.archiveExecutor.execute()
    }
    
    fileprivate func createDirectories() {
        if !FileManager.default.fileExists(atPath: baseTempDir) {
            try! FileManager.default.createDirectory(atPath: baseTempDir, withIntermediateDirectories: true, attributes: nil)
        }
        Logger.log(message: "Building at temp path: \(baseTempDir)")
    }
}

extension Application: ArchiveExecutorProtocol {
    func archiveDidFinishWithSuccess() {
        Logger.log(message: "Archive finished with success")
        // TODO: remove the exit(0) and start the export
        exit(0)
    }
    
    func archiveDidFailWithStatusCode(_ code: Int) {
        Logger.log(message: "Archive failed with status code: \(code)")
        Logger.log(message: "See logs at: \(ArchiveTool.Values.archiveLogPath)")
        exit(0)
    }
}
