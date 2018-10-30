//
//  CannonParameter.swift
//  buildcannon
//
//  Created by Anderson Lucas de Castro Ramos on 19/06/18.
//  Copyright © 2018 InsaniTech. All rights reserved.
//

import Foundation

class CannonParameter: InputParameter {
    fileprivate static let buildDependencies = [
        InputParameter.Project.scheme
    ]
    fileprivate static let distributeDependencies = [
        InputParameter.Project.scheme,
        InputParameter.Project.provisioningProfile,
        InputParameter.Project.teamId,
        InputParameter.Project.bundleIdentifier
    ]
    fileprivate static let exportDependencies = [
        InputParameter.Project.scheme,
        InputParameter.Project.provisioningProfile,
        InputParameter.Project.teamId,
        InputParameter.Project.bundleIdentifier,
        InputParameter.Output.outputPath
    ]
    fileprivate static let uploadDependencies = [
        InputParameter.Output.ipaPath
    ]
    
    fileprivate(set) var executorType: ExecutorProtocol.Type!
    
    init(name: String, type: CommandParameter.Type, dependency: [InputParameter]?, executor: ExecutorProtocol.Type) {
        super.init(name: name, type: type, dependency: dependency)
        self.executorType = executor
    }
    
    static func get(command: CommandParameter) -> InputParameter? {
        switch command.parameter {
        case self.create.name: return self.create
        case self.createTarget.name: return self.createTarget
        case self.build.name: return self.build
        case self.test.name: return self.test
        case self.distribute.name: return self.distribute
        case self.export.name: return self.export
        case self.upload.name: return self.upload
        case self.selfUpdate.name: return self.selfUpdate
        default: return nil
        }
    }
    
    static let create = CannonParameter.init(name: "create", type: NoDashParameter.self, dependency: nil, executor: CannonFileCreator.self)
    static let createTarget = CannonParameter.init(name: "create-target", type: NoDashParameter.self, dependency: nil, executor: CannonFileTargetCreator.self)
    static let build = InputParameter.init(name: "build", type: NoDashParameter.self, dependency: buildDependencies)
    static let test = InputParameter.init(name: "test", type: NoDashParameter.self, dependency: buildDependencies)
    static let distribute = CannonParameter.init(name: "distribute", type: NoDashParameter.self, dependency: distributeDependencies, executor: CannonDistribute.self)
    static let export = CannonParameter.init(name: "export", type: NoDashParameter.self, dependency: exportDependencies, executor: CannonExport.self)
    static let upload = CannonParameter.init(name: "upload", type: NoDashParameter.self, dependency: uploadDependencies, executor: CannonUpload.self)
    static let selfUpdate = CannonParameter.init(name: "self-update", type: NoDashParameter.self, dependency: nil, executor: CannonSelfUpdate.self)
}
