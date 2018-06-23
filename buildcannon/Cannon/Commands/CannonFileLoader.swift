//
//  CannonFileLoader.swift
//  buildcannon
//
//  Created by Anderson Lucas C. Ramos on 19/06/18.
//  Copyright © 2018 InsaniTech. All rights reserved.
//

import Foundation

class CannonFileLoader {
    func load() -> CannonFile? {
        let url = sourceCodeTempDir.appendingPathComponent("buildcannon")
        let finalPath = url.appendingPathComponent("default.cannon")
        if let jsonData = try? Data.init(contentsOf: finalPath) {
            let decoder = JSONDecoder.init()
            if let file = try? decoder.decode(CannonFile.self, from: jsonData) {
                return file
            }
        }
        return nil
    }
    
    func assign(file: CannonFile) {
        if self.checkParameter(value: file.appstore_connect_account, commandName: Parameter.username.name) {
            Application.processParameters.append(DoubleDashComplexParameter.init(parameter: Parameter.username.name, composition: file.appstore_connect_account!))
        }
        if self.checkParameter(value: file.build_configuration, commandName: Parameter.configuration.name) {
            Application.processParameters.append(DoubleDashComplexParameter.init(parameter: Parameter.configuration.name, composition: file.build_configuration))
        }
        if self.checkParameter(value: file.bundle_identifier, commandName: Parameter.bundleIdentifier.name) {
            Application.processParameters.append(DoubleDashComplexParameter.init(parameter: Parameter.bundleIdentifier.name, composition: file.bundle_identifier))
        }
        if self.checkParameter(value: file.project_file, commandName: Parameter.projectFile.name) {
            Application.processParameters.append(DoubleDashComplexParameter.init(parameter: Parameter.projectFile.name, composition: file.project_file!))
        }
        if self.checkParameter(value: file.provisioning_profile, commandName: Parameter.provisioningProfile.name) {
            Application.processParameters.append(DoubleDashComplexParameter.init(parameter: Parameter.provisioningProfile.name, composition: file.provisioning_profile))
        }
        if self.checkParameter(value: file.scheme, commandName: Parameter.scheme.name) {
            Application.processParameters.append(DoubleDashComplexParameter.init(parameter: Parameter.scheme.name, composition: file.scheme))
        }
        if self.checkParameter(value: file.project_file, commandName: Parameter.projectFile.name) {
            Application.processParameters.append(DoubleDashComplexParameter.init(parameter: Parameter.projectFile.name, composition: file.project_file!))
        }
        if self.checkParameter(value: file.team_id, commandName: Parameter.teamId.name) {
            Application.processParameters.append(DoubleDashComplexParameter.init(parameter: Parameter.teamId.name, composition: file.team_id))
        }
    }
    
    fileprivate func checkParameter(value: String?, commandName: String) -> Bool {
        if let value = value, !value.isEmpty {
            return !Application.processParameters.contains(where: { $0.parameter == commandName })
        }
        return false
    }
}
