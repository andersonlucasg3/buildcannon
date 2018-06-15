//
//  Consts.swift
//  buildtool
//
//  Created by Anderson Lucas C. Ramos on 13/06/18.
//  Copyright © 2018 InsaniTech. All rights reserved.
//

import Foundation

let baseTempDir = NSTemporaryDirectory() + UUID.init().uuidString

struct Parameters {
    typealias ParameterTouple = (name: String, type: CommandParameter.Type)
    
    static let projectFile: ParameterTouple = ("project-file", DoubleDashComplexParameter.self)
    static let scheme: ParameterTouple = ("scheme", DoubleDashComplexParameter.self)
    static let provisioningProfile: ParameterTouple = ("provisioning-profile", DoubleDashComplexParameter.self)
    static let teamId: ParameterTouple = ("team-id", DoubleDashComplexParameter.self)
    static let bundleIdentifier: ParameterTouple = ("bundle-identifier", DoubleDashComplexParameter.self)
    static let verbose: ParameterTouple = ("verbose", DoubleDashParameter.self)
    static let help: ParameterTouple = ("help", DoubleDashParameter.self)
    
    static let REQUIRED_PARAMETERS = [
        Parameters.projectFile,
        Parameters.scheme,
        Parameters.provisioningProfile,
        Parameters.teamId,
        Parameters.bundleIdentifier
    ]
}
