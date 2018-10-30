//
//  CannonFileLoader.swift
//  buildcannon
//
//  Created by Anderson Lucas C. Ramos on 19/06/18.
//  Copyright © 2018 InsaniTech. All rights reserved.
//

import Foundation

class CannonFileLoader {
    func listFilesNames() -> [String]? {
        let buildcannonPath = sourceCodeTempDir.appendingPathComponent("buildcannon")
        if let files = try? FileManager.default.contentsOfDirectory(atPath: buildcannonPath.path) {
            return files.map({ $0.replacingOccurrences(of: ".cannon", with: "") })
        }
        return nil
    }
    
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
    
    func assign(file: CannonFile, processParameters: inout [CommandParameter]) {
        let separator = "="
        if self.checkParameter(value: file.appstore_connect_account, commandName: InputParameter.Identity.username.name, processParameters: processParameters) {
            processParameters.append(DoubleDashComplexParameter.init(parameter: InputParameter.Identity.username.name, composition: file.appstore_connect_account!, separator: separator))
        }
        if self.checkParameter(value: file.build_configuration, commandName: InputParameter.Project.configuration.name, processParameters: processParameters), let build_configuration = file.build_configuration {
            processParameters.append(DoubleDashComplexParameter.init(parameter: InputParameter.Project.configuration.name, composition: build_configuration, separator: separator))
        }
        if self.checkParameter(value: file.bundle_identifier, commandName: InputParameter.Project.bundleIdentifier.name, processParameters: processParameters), let bundle_identifier = file.bundle_identifier {
            processParameters.append(DoubleDashComplexParameter.init(parameter: InputParameter.Project.bundleIdentifier.name, composition: bundle_identifier, separator: separator))
        }
        if self.checkParameter(value: file.project_file, commandName: InputParameter.Project.projectFile.name, processParameters: processParameters), let project_file = file.project_file {
            processParameters.append(DoubleDashComplexParameter.init(parameter: InputParameter.Project.projectFile.name, composition: project_file, separator: separator))
        }
        if self.checkParameter(value: file.provisioning_profile, commandName: InputParameter.Project.provisioningProfile.name, processParameters: processParameters), let provisioning_profile = file.provisioning_profile {
            processParameters.append(DoubleDashComplexParameter.init(parameter: InputParameter.Project.provisioningProfile.name, composition: provisioning_profile, separator: separator))
        }
        if self.checkParameter(value: file.scheme, commandName: InputParameter.Project.scheme.name, processParameters: processParameters), let scheme = file.scheme {
            processParameters.append(DoubleDashComplexParameter.init(parameter: InputParameter.Project.scheme.name, composition: scheme, separator: separator))
        }
        if self.checkParameter(value: file.team_id, commandName: InputParameter.Project.teamId.name, processParameters: processParameters), let team_id = file.team_id {
            processParameters.append(DoubleDashComplexParameter.init(parameter: InputParameter.Project.teamId.name, composition: team_id, separator: separator))
        }
        if self.checkParameter(value: file.sdk, commandName: InputParameter.Project.sdk.name, processParameters: processParameters), let sdk = file.sdk {
            processParameters.append(DoubleDashComplexParameter.init(parameter: InputParameter.Project.sdk.name, composition: sdk, separator: separator))
        }
        if self.checkParameter(value: file.top_shelf_bundle_identifier, commandName: InputParameter.Project.topShelfBundleIdentifier.name, processParameters: processParameters), let top_shelf_bundle_identifier = file.top_shelf_bundle_identifier {
            processParameters.append(DoubleDashComplexParameter.init(parameter: InputParameter.Project.topShelfBundleIdentifier.name, composition: top_shelf_bundle_identifier, separator: separator))
        }
        if self.checkParameter(value: file.top_shelf_provisioning_profile, commandName: InputParameter.Project.topShelfProvisioningProfile.name, processParameters: processParameters), let top_shelf_provisioning_profile = file.top_shelf_provisioning_profile {
            processParameters.append(DoubleDashComplexParameter.init(parameter: InputParameter.Project.topShelfProvisioningProfile.name, composition: top_shelf_provisioning_profile, separator: separator))
        }
    }
    
    fileprivate func checkParameter(value: String?, commandName: String, processParameters: [CommandParameter]) -> Bool {
        if let value = value, !value.isEmpty {
            return !processParameters.contains(where: { $0.parameter == commandName })
        }
        return false
    }
}
