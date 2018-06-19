//
//  Parameters.swift
//  buildcannon
//
//  Created by Anderson Lucas C. Ramos on 13/06/18.
//  Copyright © 2018 InsaniTech. All rights reserved.
//

import Foundation

let baseTempDir = NSTemporaryDirectory() + UUID.init().uuidString

struct Parameter {
    let name: String
    let type: CommandParameter.Type
    let dependency: [Parameter]?
    
    init(name: String, type: CommandParameter.Type, dependency: [Parameter]? = nil) {
        self.name = name
        self.type = type
        self.dependency = dependency
    }
    
    static let projectFile = Parameter.init(name: "project-file", type: DoubleDashComplexParameter.self)
    static let scheme = Parameter.init(name: "scheme", type: DoubleDashComplexParameter.self)
    static let provisioningProfile = Parameter.init(name: "provisioning-profile", type: DoubleDashComplexParameter.self)
    static let teamId = Parameter.init(name: "team-id", type: DoubleDashComplexParameter.self)
    static let bundleIdentifier = Parameter.init(name: "bundle-identifier", type: DoubleDashComplexParameter.self)
    static let verbose = Parameter.init(name: "verbose", type: DoubleDashParameter.self)
    static let help = Parameter.init(name: "help", type: DoubleDashParameter.self)
    static let archivePath = Parameter.init(name: "archive-path", type: DoubleDashComplexParameter.self)
    static let ipaPath = Parameter.init(name: "ipa-path", type: DoubleDashComplexParameter.self)
    static let username = Parameter.init(name: "username", type: DoubleDashComplexParameter.self)
    static let password = Parameter.init(name: "password", type: DoubleDashComplexParameter.self)
}
