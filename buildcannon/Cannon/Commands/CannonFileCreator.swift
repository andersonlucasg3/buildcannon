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
     "project_file": "[projName].[xcworkspace|xcodeproj]",
     "appstore_connect_account": "your@email.com",
     "build_configuration": "Release", // default if not specified
     "target": "target name"
 }
 
 */

struct CannonFile: Codable {
    var scheme: String
    var team_id: String
    var bundle_identifier: String
    var provisioning_profile: String
    
    var project_file: String?
    var appstore_connect_account: String?
    var build_configuration: String = "Release"
    var target: String?
    
    static func from(info: UserProjectInfo) -> CannonFile {
        let file = CannonFile.init(scheme: info.scheme,
                                   team_id: info.teamId,
                                   bundle_identifier: info.bundleIdentifier,
                                   provisioning_profile: info.provisioningProfile,
                                   project_file: nil,
                                   appstore_connect_account: info.account,
                                   build_configuration: info.buildConfig,
                                   target: info.target)
        return file
    }
}

typealias ProjectInfo = (projectName: String, targets: [String], buildConfigs: [String], schemes: [String])
typealias UserProjectInfo = (scheme: String, target: String?, buildConfig: String, teamId: String,
                             provisioningProfile: String, account: String?, bundleIdentifier: String)

class CannonFileCreator: ExecutorProtocol {
    fileprivate var currentExecutor: CommandExecutor!
    
    weak var delegate: ExecutorCompletionProtocol?
    
    required init() {
        
    }
    
    func execute() {
        self.getInformation { (info) in
            self.askUserQuestions(with: info, completion: { (userInfo) in
                self.createFile(userConfig: userInfo)
            })
        }
    }
    
    func cancel() {
        self.currentExecutor.stop()
    }
    
    fileprivate func getBundleIdentifier(with targetName: String, completion: @escaping (String) -> Void) {
        self.currentExecutor = CommandExecutor.init(path: ArchiveTool.toolPath, application: ArchiveTool.toolName, logFilePath: "\(baseTempDir)/bundleIdentifier.log")
        self.currentExecutor.add(parameter: SingleDashParameter.init(parameter: "showBuildSettings"))
        self.currentExecutor.add(parameter: SingleDashComplexParameter.init(parameter: "target", composition: targetName))
        self.currentExecutor.add(parameter: NoDashParameter.init(parameter: "| grep PRODUCT_BUNDLE_IDENTIFIER"))
        self.currentExecutor.add(parameter: NoDashParameter.init(parameter: "| awk -F ' = ' '{print $2}'"))
        #if DEBUG
        Console.log(message: "Executing command: \(self.currentExecutor.buildCommandString())")
        #endif
        self.currentExecutor.execute(tag: "get bundle identifier") { (result, output) in
            guard result == 0 else {
                Application.execute {
                    self.dispatchFailure(result)
                }
                return
            }
            
            Application.execute {
                completion(String.init(output?.split(separator: "\n").last ?? ""))
            }
        }
    }
    
    fileprivate func askUserQuestions(with info: ProjectInfo, completion: @escaping (UserProjectInfo) -> Void) {
        var scheme = info.schemes.first ?? ""
        var target = info.targets.first
        var buildConfig = info.buildConfigs.first(where: {$0 == "Release"}) ?? info.buildConfigs.first ?? ""
        var teamId = ""
        var account: String?
        var provisioningProfile = ""
        Console.log(message: "Creating `default.cannon` file for project \(info.projectName)")
        Console.log(message: "Schemes: \n\(info.schemes.joined(separator: "\n"))")
        Console.readInput(message: "Which scheme would you like to use by default? [\(scheme)]") { (line) in
            scheme = line ?? info.schemes.first ?? ""
        }
        Console.log(message: "Targets: \n\(info.targets.joined(separator: "\n"))")
        Console.readInput(message: "Which target would you like to use by default? [\(target ?? "")]") { (line) in
            target = line ?? info.targets.first
        }
        Console.log(message: "Build Configurations: \n\(info.buildConfigs.joined(separator: "\n"))")
        Console.readInput(message: "Which build configurations would you like to use by default? [\(buildConfig)]") { (line) in
            buildConfig = line ?? buildConfig
        }
        Console.readInput(message: "Please inform your AppStore Connect Team Id: ") { (line) in
            teamId = line ?? ""
        }
        Console.readInput(message: "Please inform your AppStore Connect Account: ") { (line) in
            account = line
        }
        Console.readInput(message: "Please inform your Provisioning Profile name: ") { (line) in
            provisioningProfile = line ?? ""
        }
        self.getBundleIdentifier(with: target ?? "", completion: { bundle in
            completion((scheme, target, buildConfig, teamId, provisioningProfile, account, bundle))
        })
    }
    
    fileprivate func getInformation(completion: @escaping (ProjectInfo) -> Void) {
        self.currentExecutor = CommandExecutor.init(path: ArchiveTool.toolPath, application: ArchiveTool.toolName, logFilePath: "\(baseTempDir)/listSchemes.log")
        self.currentExecutor.add(parameter: SingleDashParameter.init(parameter: "list"))
        self.currentExecutor.execute(tag: "list schemes") { (result, output) in
            guard result == 0 && output != nil else {
                Application.execute {
                    self.dispatchFailure(result)
                }
                return
            }
            let parser = XcodeListParser.init(content: output ?? "")
            let content = parser.parse()
            Application.execute {
                completion(content)
            }
        }
    }
    
    fileprivate func createFile(userConfig: UserProjectInfo) {
        let cannonFile = CannonFile.from(info: userConfig)
        let encoder = JSONEncoder.init()
        let string = try? encoder.encode(cannonFile)
        let path = FileManager.default.currentDirectoryPath
        let url = URL(fileURLWithPath: path).appendingPathComponent("buildcannon")
        let finalPath = url.appendingPathComponent("default.cannon")
        try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        try! string!.write(to: finalPath, options: .atomic)
        
        Application.execute {
            self.dispatchSuccess(path: finalPath.absoluteString)
        }
    }
    
    fileprivate func dispatchFailure(_ code: Int) {
        Console.log(message: "Cannon project file creation failed with code: \(code)")
        self.delegate?.executor(self, didFailWithErrorCode: code)
    }
    
    fileprivate func dispatchSuccess(path: String) {
        Console.log(message: "Cannon project file created at: \(path)")
        self.delegate?.executorDidFinishWithSuccess(self)
    }
}

struct XcodeListParser {
    private let content: String
    init(content: String) {
        self.content = content
    }
    
    func parse() -> ProjectInfo {
        let lines = self.content.split(separator: "\n")
        guard lines.count > 0 else { return ("", [], [], []) }
        let projectName = self.getProjectName(firstLine: String(lines.first ?? ""))
        let targets = self.getGrouped(groupName: "Targets:", string: self.content)
        let buildConfigurations = self.getGrouped(groupName: "Build Configurations:", string: self.content)
        let schemes = self.getGrouped(groupName: "Schemes:", string: self.content)
        
        return (projectName, targets, buildConfigurations, schemes)
    }
    
    private func extract(from string: String, match: NSTextCheckingResult) -> String {
        let start = String.UTF8Index.init(encodedOffset: match.range.location + 1)
        let end = String.UTF8Index.init(encodedOffset: match.range.location + match.range.length - 1)
        return String.init(string[start..<end])
    }
    
    private func getProjectName(firstLine: String) -> String {
        let regex = try? NSRegularExpression.init(pattern: "\\\"([A-Za-z-\\s]+)\\\"")
        if let match = regex?.firstMatch(in: firstLine, options: .reportCompletion, range: NSRange.init(location: 0, length: firstLine.count)) {
            return self.extract(from: firstLine, match: match)
        }
        return ""
    }
    
    private func getGrouped(groupName: String, string: String) -> [String] {
        let regex = try? NSRegularExpression.init(pattern: "\(groupName)(\\s+[A-Za-z-]+)+\\n\\n")
        if let match = regex?.firstMatch(in: string, options: .reportCompletion, range: NSRange.init(location: 0, length: string.count)) {
            let values = self.extract(from: string, match: match).split(separator: "\n").map({String.init($0)})
            if values.count > 1 {
                return Array.init(values.suffix(from: 1)).map({$0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)})
            }
        }
        return []
    }
}
