//
//  CannonFileCreator.swift
//  buildcannon
//
//  Created by Anderson Lucas de Castro Ramos on 19/06/18.
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
     "profile_file": "[projName].[xcworkspace|xcodeproj]",
     "appstore_connect_account": "your@email.com",
     "build_configuration": "Release" // default if not specified
 }
 
 */

class CannonFileCreator: ExecutorProtocol {
    init() {
        
    }
    
    func execute() {
        let listSchemes = CommandExecutor.init(path: ArchiveTool.toolPath, application: ArchiveTool.toolName, logFilePath: nil)
        listSchemes.add(parameter: SingleDashParameter.init(parameter: "list"))
        listSchemes.execute(tag: "list schemes") { (result, output) in
            Application.execute {
                
            }
        }
    }
    
    func cancel() {
        
    }
}

struct XcodeListParser {
    fileprivate let content: String
    init(content: String) {
        self.content = content
    }
    
    func parse() -> (buildConfigs: [String], schemes: [String]) {
        var position = 0
        let lines = self.content.split(separator: "\n")
        guard lines.count > 0 else { return ([], []) }
        let projectName = self.getProjectName(firstLine: String(lines[position]))
        position += 1
        guard lines.count > position else { return ([], []) }
        if lines[position].contains("Targets:") {
            
        }
    }
    
    fileprivate func getProjectName(firstLine: String) -> String? {
        if let index = firstLine.index(of: "\"") {
            let name = firstLine[index..<firstLine.index(firstLine.endIndex, offsetBy: -1)]
            return name.replacingOccurrences(of: "\"", with: "")
        }
        return nil
    }
    
    fileprivate func getTargets(targetsSlice: ArraySlice<String>) -> [String] {
        
    }
}
