//
//  CannonParameter.swift
//  buildcannon
//
//  Created by Anderson Lucas de Castro Ramos on 19/06/18.
//  Copyright © 2018 InsaniTech. All rights reserved.
//

import Foundation

class CannonParameter: Parameter {
    fileprivate static let buildDependencies = [
        Parameter.scheme
    ]
    fileprivate static let distributeDependencies = [
        Parameter.scheme,
        Parameter.provisioningProfile,
        Parameter.teamId,
        Parameter.bundleIdentifier
    ]
    fileprivate static let exportDependencies = [
        Parameter.scheme,
        Parameter.provisioningProfile,
        Parameter.teamId,
        Parameter.bundleIdentifier,
        Parameter.outputPath
    ]
    fileprivate static let uploadDependencies = [
        Parameter.ipaPath
    ]
    
    fileprivate(set) var executorType: ExecutorProtocol.Type!
    
    init(name: String, type: CommandParameter.Type, dependency: [Parameter]?, executor: ExecutorProtocol.Type) {
        super.init(name: name, type: type, dependency: dependency)
        self.executorType = executor
    }
    
    static func get(command: CommandParameter) -> Parameter? {
        switch command.parameter {
        case self.create.name: return self.create
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
    static let build = Parameter.init(name: "build", type: NoDashParameter.self, dependency: buildDependencies)
    static let test = Parameter.init(name: "test", type: NoDashParameter.self, dependency: buildDependencies)
    static let distribute = CannonParameter.init(name: "distribute", type: NoDashParameter.self, dependency: distributeDependencies, executor: CannonDistribute.self)
    static let export = CannonParameter.init(name: "export", type: NoDashParameter.self, dependency: exportDependencies, executor: CannonExport.self)
    static let upload = Parameter.init(name: "upload", type: NoDashParameter.self, dependency: uploadDependencies)
    static let selfUpdate = CannonParameter.init(name: "self-update", type: NoDashParameter.self, dependency: nil, executor: CannonSelfUpdate.self)
}
