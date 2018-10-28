//
//  CannonFileLoader.swift
//  buildcannon
//
//  Created by Anderson Lucas C. Ramos on 19/06/18.
//  Copyright © 2018 InsaniTech. All rights reserved.
//

import Foundation

class CannonFileLoader {
    func load(target: String?) -> CannonFile? {
        if let file = self.loadFile(for: "default") {
            if let target = target {
                if let overrideFile = self.loadTargetOverride(in: file, target: target) {
                    return overrideFile
                }
                return nil
            }
            return file
        }
        return nil
    }
    
    fileprivate func loadFile(for name: String) -> CannonFile? {
        let url = sourceCodeTempDir.appendingPathComponent("buildcannon")
        let finalPath = url.appendingPathComponent("\(name).cannon")
        if let jsonData = try? Data.init(contentsOf: finalPath) {
            let decoder = JSONDecoder.init()
            if let file = try? decoder.decode(CannonFile.self, from: jsonData) {
                return file
            }
        }
        return nil
    }
    
    fileprivate func loadTargetOverride(in file: CannonFile, target: String) -> CannonFile? {
        func set<T>(current: inout T?, `default`: T?) {
            current = current ?? `default`
        }
        
        if var cannonFile = self.loadFile(for: target) {
            set(current: &cannonFile.appstore_connect_account, default: file.appstore_connect_account)
            set(current: &cannonFile.build_configuration, default: file.build_configuration)
            set(current: &cannonFile.bundle_identifier, default: file.bundle_identifier)
            set(current: &cannonFile.pre_build_commands, default: file.pre_build_commands)
            set(current: &cannonFile.project_file, default: file.project_file)
            set(current: &cannonFile.provisioning_profile, default: file.provisioning_profile)
            set(current: &cannonFile.scheme, default: file.scheme)
            set(current: &cannonFile.sdk, default: file.sdk)
            set(current: &cannonFile.team_id, default: file.team_id)
            set(current: &cannonFile.top_shelf_bundle_identifier, default: file.top_shelf_bundle_identifier)
            set(current: &cannonFile.top_shelf_provisioning_profile, default: file.top_shelf_provisioning_profile)
            return cannonFile
        }
        return nil
    }
    
    func assign(file: CannonFile) {
        if self.checkParameter(value: file.appstore_connect_account, commandName: InputParameter.username.name) {
            Application.processParameters.append(DoubleDashComplexParameter.init(parameter: InputParameter.username.name, composition: file.appstore_connect_account!))
        }
        if self.checkParameter(value: file.build_configuration, commandName: InputParameter.configuration.name), let build_configuration = file.build_configuration {
            Application.processParameters.append(DoubleDashComplexParameter.init(parameter: InputParameter.configuration.name, composition: build_configuration))
        }
        if self.checkParameter(value: file.bundle_identifier, commandName: InputParameter.bundleIdentifier.name), let bundle_identifier = file.bundle_identifier {
            Application.processParameters.append(DoubleDashComplexParameter.init(parameter: InputParameter.bundleIdentifier.name, composition: bundle_identifier))
        }
        if self.checkParameter(value: file.project_file, commandName: InputParameter.projectFile.name), let project_file = file.project_file {
            Application.processParameters.append(DoubleDashComplexParameter.init(parameter: InputParameter.projectFile.name, composition: project_file))
        }
        if self.checkParameter(value: file.provisioning_profile, commandName: InputParameter.provisioningProfile.name), let provisioning_profile = file.provisioning_profile {
            Application.processParameters.append(DoubleDashComplexParameter.init(parameter: InputParameter.provisioningProfile.name, composition: provisioning_profile))
        }
        if self.checkParameter(value: file.scheme, commandName: InputParameter.scheme.name), let scheme = file.scheme {
            Application.processParameters.append(DoubleDashComplexParameter.init(parameter: InputParameter.scheme.name, composition: scheme))
        }
        if self.checkParameter(value: file.team_id, commandName: InputParameter.teamId.name), let team_id = file.team_id {
            Application.processParameters.append(DoubleDashComplexParameter.init(parameter: InputParameter.teamId.name, composition: team_id))
        }
        if self.checkParameter(value: file.sdk, commandName: InputParameter.sdk.name), let sdk = file.sdk {
            Application.processParameters.append(DoubleDashComplexParameter.init(parameter: InputParameter.sdk.name, composition: sdk))
        }
        if self.checkParameter(value: file.top_shelf_bundle_identifier, commandName: InputParameter.topShelfBundleIdentifier.name), let top_shelf_bundle_identifier = file.top_shelf_bundle_identifier {
            Application.processParameters.append(DoubleDashComplexParameter.init(parameter: InputParameter.topShelfBundleIdentifier.name, composition: top_shelf_bundle_identifier))
        }
        if self.checkParameter(value: file.top_shelf_provisioning_profile, commandName: InputParameter.topShelfProvisioningProfile.name), let top_shelf_provisioning_profile = file.top_shelf_provisioning_profile {
            Application.processParameters.append(DoubleDashComplexParameter.init(parameter: InputParameter.topShelfProvisioningProfile.name, composition: top_shelf_provisioning_profile))
        }
    }
    
    fileprivate func checkParameter(value: String?, commandName: String) -> Bool {
        if let value = value, !value.isEmpty {
            return !Application.processParameters.contains(where: { $0.parameter == commandName })
        }
        return false
    }
}
