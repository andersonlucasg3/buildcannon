//
//  CannonParameters.swift
//  buildcannon
//
//  Created by Anderson Lucas de Castro Ramos on 19/06/18.
//  Copyright © 2018 InsaniTech. All rights reserved.
//

import Foundation

struct CannonParameters {
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
        Parameter.archivePath,
        Parameter.provisioningProfile,
        Parameter.teamId,
        Parameter.bundleIdentifier
    ]
    fileprivate static let uploadDependencies = [
        Parameter.ipaPath
    ]
    
    static let create = Parameter.init(name: "create", type: NoDashParameter.self)
    static let build = Parameter.init(name: "build", type: NoDashParameter.self, dependency: buildDependencies)
    static let test = Parameter.init(name: "test", type: NoDashParameter.self, dependency: buildDependencies)
    static let distribute = Parameter.init(name: "distribute", type: NoDashParameter.self, dependency: distributeDependencies)
    static let export = Parameter.init(name: "export", type: NoDashParameter.self, dependency: exportDependencies)
    static let upload = Parameter.init(name: "upload", type: NoDashParameter.self, dependency: uploadDependencies)
}
