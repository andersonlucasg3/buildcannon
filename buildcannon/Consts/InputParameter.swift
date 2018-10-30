//
//  InputParameter.swift
//  buildcannon
//
//  Created by Anderson Lucas C. Ramos on 13/06/18.
//  Copyright © 2018 InsaniTech. All rights reserved.
//

import Foundation

let baseTempDir = NSTemporaryDirectory() + UUID.init().uuidString
let sourceCodeTempDir = URL(fileURLWithPath: baseTempDir).appendingPathComponent("sourcecode")
let processWorkingDir = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)

class InputParameter {
    let name: String
    let type: CommandParameter.Type
    let dependency: [InputParameter]?
    
    init(name: String, type: CommandParameter.Type, dependency: [InputParameter]? = nil) {
        self.name = name
        self.type = type
        self.dependency = dependency
    }
    
    struct Project {
        static let projectFile = InputParameter.init(name: "project-file", type: DoubleDashComplexParameter.self)
        static let scheme = InputParameter.init(name: "scheme", type: DoubleDashComplexParameter.self)
        static let target = InputParameter.init(name: "target", type: DoubleDashComplexParameter.self)
        static let configuration = InputParameter.init(name: "configuration", type: DoubleDashComplexParameter.self)
        static let sdk = InputParameter.init(name: "sdk", type: DoubleDashComplexParameter.self)
        static let provisioningProfile = InputParameter.init(name: "provisioning-profile", type: DoubleDashComplexParameter.self)
        static let topShelfProvisioningProfile = InputParameter.init(name: "top-shelf-provisioning-profile", type: DoubleDashComplexParameter.self)
        static let teamId = InputParameter.init(name: "team-id", type: DoubleDashComplexParameter.self)
        static let bundleIdentifier = InputParameter.init(name: "bundle-identifier", type: DoubleDashComplexParameter.self)
        static let topShelfBundleIdentifier = InputParameter.init(name: "top-shelf-bundle-identifier", type: DoubleDashComplexParameter.self)
        static let exportMethod = InputParameter.init(name: "export-method", type: DoubleDashComplexParameter.self)
        
        fileprivate init() { }
    }
    
    struct Distribute {
        static let all = InputParameter.init(name: "all", type: DoubleDashParameter.self)
        static let targets = InputParameter.init(name: "targets", type: DoubleDashComplexParameter.self)
        
        fileprivate init() { }
    }
    
    struct Application {
        static let verbose = InputParameter.init(name: "verbose", type: DoubleDashParameter.self)
        static let help = InputParameter.init(name: "help", type: DoubleDashParameter.self)
        static let version = InputParameter.init(name: "version", type: DoubleDashComplexParameter.self)
        
        fileprivate init() { }
    }
    
    struct Output {
        static let archivePath = InputParameter.init(name: "archive-path", type: DoubleDashComplexParameter.self)
        static let ipaPath = InputParameter.init(name: "ipa-path", type: DoubleDashComplexParameter.self)
        static let outputPath = InputParameter.init(name: "output-path", type: DoubleDashComplexParameter.self)
        
        fileprivate init() { }
    }
    
    struct Identity {
        static let username = InputParameter.init(name: "username", type: DoubleDashComplexParameter.self)
        static let password = InputParameter.init(name: "password", type: DoubleDashComplexParameter.self)
        
        fileprivate init() { }
    }
}
