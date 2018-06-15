//
//  ArchiveExecutor.swift
//  buildtool
//
//  Created by Anderson Lucas C. Ramos on 13/06/18.
//  Copyright © 2018 Anderson Lucas C. Ramos. All rights reserved.
//

import Foundation

protocol ArchiveExecutorProtocol: class {
    func archiveDidFinishWithSuccess()
    func archiveDidFailWithStatusCode(_ code: Int)
}

class ArchiveExecutor {
    fileprivate var commandExecutor: CommandExecutor!
    
    weak var delegate: ArchiveExecutorProtocol?
    
    init(project: DoubleDashComplexParameter, scheme: DoubleDashComplexParameter) {
        let archive = CommandExecutor.init(path: "/usr/bin/", application: ArchiveTool.toolName, logFilePath: ArchiveTool.Values.archiveLogPath)
        archive.add(parameter: SingleDashComplexParameter.init(parameter: self.projectParam(for: project), composition: project.composition))
        archive.add(parameter: SingleDashComplexParameter.init(parameter: ArchiveTool.Parameters.schemeParam, composition: scheme.composition))
        archive.add(parameter: SingleDashComplexParameter.init(parameter: ArchiveTool.Parameters.sdkParam, composition: ArchiveTool.Values.sdkConfig))
        archive.add(parameter: SingleDashComplexParameter.init(parameter: ArchiveTool.Parameters.configurationParam, composition: ArchiveTool.Values.configurationConfig))
        archive.add(parameter: NoDashParameter.init(parameter: ArchiveTool.Parameters.archiveParam))
        archive.add(parameter: SingleDashComplexParameter.init(parameter: ArchiveTool.Parameters.archivePathParam, composition: ArchiveTool.Values.archivePath))
        archive.add(parameter: NoDashParameter.init(parameter: "| xcpretty"))
        self.commandExecutor = archive
    }
    
    fileprivate func projectParam(for parameter: DoubleDashComplexParameter) -> String {
        return parameter.buildParameter().contains(".xcworkspace") ?
            ArchiveTool.Parameters.workspaceParam : ArchiveTool.Parameters.projectParam
    }
    
    fileprivate func dispatchFinish(_ returnCode: Int) {
        DispatchQueue.main.async { [weak self] in
            if returnCode != 0 {
                self?.delegate?.archiveDidFailWithStatusCode(returnCode)
            } else {
                self?.delegate?.archiveDidFinishWithSuccess()
            }
        }
    }
    
    func execute() {
        Logger.log(message: "Executing archive with command: \(self.commandExecutor.buildCommandString())")
        self.commandExecutor.execute { [weak self] (returnCode) in
            self?.dispatchFinish(returnCode)
        }
    }
    
    func cancel() {
        self.commandExecutor.stop()
    }
}
