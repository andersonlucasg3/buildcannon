//
//  ArchiveExecutor.swift
//  buildcannon
//
//  Created by Anderson Lucas C. Ramos on 13/06/18.
//  Copyright © 2018 InsaniTech. All rights reserved.
//

import Foundation

protocol ArchiveExecutorProtocol: class {
    func archiveDidFinishWithSuccess()
    func archiveDidFailWithStatusCode(_ code: Int)
}

class ArchiveExecutor: ExecutorProtocol {
    fileprivate var commandExecutor: CommandExecutor!
    
    weak var delegate: ArchiveExecutorProtocol?
    
    init(project: DoubleDashComplexParameter, scheme: DoubleDashComplexParameter) {
        self.commandExecutor = CommandExecutor.init(path: "/usr/bin/", application: ArchiveTool.toolName, logFilePath: ArchiveTool.Values.archiveLogPath)
        self.commandExecutor.add(parameter: SingleDashComplexParameter.init(parameter: self.projectParam(for: project), composition: project.composition))
        self.commandExecutor.add(parameter: SingleDashComplexParameter.init(parameter: ArchiveTool.Parameters.schemeParam, composition: scheme.composition))
        self.commandExecutor.add(parameter: SingleDashComplexParameter.init(parameter: ArchiveTool.Parameters.sdkParam, composition: ArchiveTool.Values.sdkConfig))
        self.commandExecutor.add(parameter: SingleDashComplexParameter.init(parameter: ArchiveTool.Parameters.configurationParam, composition: ArchiveTool.Values.configurationConfig))
        self.commandExecutor.add(parameter: NoDashParameter.init(parameter: ArchiveTool.Parameters.archiveParam))
        self.commandExecutor.add(parameter: SingleDashComplexParameter.init(parameter: ArchiveTool.Parameters.archivePathParam, composition: ArchiveTool.Values.archivePath))
        let xcpretty = !Application.isVerbose && Application.isXcprettyInstalled
        if xcpretty {
            self.commandExecutor.add(parameter: NoDashParameter.init(parameter: "| xcpretty && exit ${PIPESTATUS[0]}"))
        }
    }
    
    fileprivate func projectParam(for parameter: DoubleDashComplexParameter) -> String {
        return parameter.buildParameter().contains(".xcworkspace") ?
            ArchiveTool.Parameters.workspaceParam : ArchiveTool.Parameters.projectParam
    }
    
    fileprivate func dispatchFinish(_ returnCode: Int) {
        Application.execute { [weak self] in
            if returnCode != 0 {
                self?.delegate?.archiveDidFailWithStatusCode(returnCode)
            } else {
                self?.delegate?.archiveDidFinishWithSuccess()
            }
        }
    }
    
    func execute() {
        Console.log(message: "Executing archive with command: \(self.commandExecutor.buildCommandString())")
        self.commandExecutor.execute(tag: "ArchiveExecutor") { [weak self] (returnCode, _) in
            self?.dispatchFinish(returnCode)
        }
    }
    
    func cancel() {
        self.commandExecutor.stop()
    }
}
