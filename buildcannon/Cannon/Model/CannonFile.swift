//
//  CannonFile.swift
//  buildcannon
//
//  Created by Anderson Lucas C. Ramos on 30/10/18.
//  Copyright © 2018 InsaniTech. All rights reserved.
//

import Foundation

/*
 Cannon file specification
 
 default.cannon
 
 {
 // REQUIRED
 "scheme": "scheme name",
 "team_id": "LKASJF235AF",
 "bundle_identifier": "com.yourcompany.yourapp",
 "provisioning_profile": "your provisioning profile name",
 
 // NOT REQUIRED
 "project_file": "[projName].[xcworkspace|xcodeproj]",
 "appstore_connect_account": "your@email.com",
 "build_configuration": "Release", // default if not specified
 "target": "target name"
 }
 
 */

typealias ProjectInfo = (projectName: String, targets: [String], buildConfigs: [String], schemes: [String])
typealias UserProjectInfo = (projectFile: String, scheme: String, buildConfig: String, exportMethod: String?, teamId: String,
    provisioningProfile: String, account: String?, bundleIdentifier: String, target: String)

struct CannonFile: Codable {
    var scheme: String?
    var team_id: String?
    var bundle_identifier: String?
    var provisioning_profile: String?
    var export_method: String?
    
    var project_file: String?
    var appstore_connect_account: String?
    var build_configuration: String?
    
    var pre_build_commands: [String]?
    
    var top_shelf_provisioning_profile: String?
    var top_shelf_bundle_identifier: String?
    var sdk: String?
    
    static func from(info: UserProjectInfo) -> CannonFile {
        let file = CannonFile.init(scheme: info.scheme,
                                   team_id: info.teamId,
                                   bundle_identifier: info.bundleIdentifier,
                                   provisioning_profile: info.provisioningProfile,
                                   export_method: info.exportMethod,
                                   project_file: info.projectFile,
                                   appstore_connect_account: info.account,
                                   build_configuration: info.buildConfig,
                                   pre_build_commands: nil,
                                   top_shelf_provisioning_profile: nil,
                                   top_shelf_bundle_identifier: nil,
                                   sdk: nil)
        return file
    }
}
