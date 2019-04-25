//
//  CannonFileCreator.swift
//  buildcannon
//
//  Created by Anderson Lucas de Castro Ramos on 19/06/18.
//  Copyright © 2018 InsaniTech. All rights reserved.
//

import Foundation

class CannonFileCreator: ExecutorProtocol {
    fileprivate let separator = "="
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
        self.currentExecutor.add(parameter: SingleDashComplexParameter.init(parameter: "target", composition: targetName, separator: self.separator))
        self.currentExecutor.add(parameter: NoDashParameter.init(parameter: "| grep PRODUCT_BUNDLE_IDENTIFIER"))
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
            
            let value = output ?? ""
            let regex = try? NSRegularExpression.init(pattern: "PRODUCT_BUNDLE_IDENTIFIER = ([a-zA-Z0-9.]+)")
            if let match = regex?.firstMatch(in: value, options: .reportCompletion, range: NSRange.init(location: 0, length: value.count)) {
                Application.execute {
                    let bundle = extract(from: value, match: match).replacingOccurrences(of: "PRODUCT_BUNDLE_IDENTIFIER = ", with: "")
                    completion(bundle)
                }
            }
        }
    }
    
    fileprivate func projectNameChecking(_ projectFile: String) -> String {
        if !projectFile.hasSuffix(".xcworkspace") && !projectFile.hasSuffix(".xcodeproj") {
            let path = URL.init(fileURLWithPath: FileManager.default.currentDirectoryPath)
            let workspaceFileName = "\(projectFile).xcworkspace"
            let projectFileName = "\(projectFile).xcodeproj"
            let workspace = path.appendingPathComponent(workspaceFileName)
            let project = path.appendingPathComponent(projectFileName)
            var dir: ObjCBool = true
            if FileManager.default.fileExists(atPath: workspace.path, isDirectory: &dir) {
                return workspaceFileName
            } else if FileManager.default.fileExists(atPath: project.path, isDirectory: &dir) {
                return projectFileName
            }
        }
        return projectFile
    }
    
    fileprivate func askUserQuestions(with info: ProjectInfo, completion: @escaping (UserProjectInfo) -> Void) {
        var projectFile = info.projectName
        var scheme = info.schemes.first ?? ""
        var target = info.targets.first
        var buildConfig = info.buildConfigs.first(where: {$0 == "Release"}) ?? info.buildConfigs.first ?? ""
        var teamId = ""
        var account: String?
        var provisioningProfile = ""
        Console.log(message: "Creating `*.cannon` file for project \(projectFile)")
        Console.readInput(message: "Enter the workspace or project name. [\(projectFile).(xcworkspace|xcodeproj)]: ") { (line) in
            projectFile = self.projectNameChecking(line ?? projectFile)
        }
        Console.log(message: "Schemes: \n\(info.schemes.joined(separator: "\n"))")
        Console.readInput(message: "Which scheme would you like to use by default? [\(scheme)]: ") { (line) in
            scheme = line ?? info.schemes.first ?? ""
        }
        Console.log(message: "Targets: \n\(info.targets.joined(separator: "\n"))")
        Console.readInput(message: "Which target would you like to use by default? [\(target ?? "")]: ") { (line) in
            target = line ?? info.targets.first
        }
        Console.log(message: "Build Configurations: \n\(info.buildConfigs.joined(separator: "\n"))")
        Console.readInput(message: "Which build configurations would you like to use by default? [\(buildConfig)]: ") { (line) in
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
            completion((projectFile, scheme, buildConfig, nil, teamId, provisioningProfile, account, bundle, target ?? "default"))
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
    
    func cannonFileName(target: String) -> String {
        return "default.cannon"
    }
    
    fileprivate func createFile(userConfig: UserProjectInfo) {
        let cannonFile = CannonFile.from(info: userConfig)
        let encoder = JSONEncoder.init()
        encoder.outputFormatting = .prettyPrinted
        let string = try? encoder.encode(cannonFile)
        let path = FileManager.default.currentDirectoryPath
        let url = URL(fileURLWithPath: path).appendingPathComponent("buildcannon")
        let finalPath = url.appendingPathComponent(self.cannonFileName(target: userConfig.target))
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

private func extract(from string: String, match: NSTextCheckingResult) -> String {
    let start = string.index(string.startIndex, offsetBy: match.range.location)
    let end = string.index(string.startIndex, offsetBy: match.range.location + match.range.length)
    return String.init(string[start..<end])
}

struct XcodeListParser {
    private let content: String
    init(content: String) {
        self.content = content
    }
    
    func parse() -> ProjectInfo {
        let lines = self.content.split(separator: "\n")
        guard lines.count > 0 else { return ("", [], [], []) }
        let projectName = self.getProjectName(firstLine: String(lines.first ?? "")).replacingOccurrences(of: "\"", with: "")
        let targets = self.getGrouped(groupName: "Targets:", string: self.content)
        let buildConfigurations = self.getGrouped(groupName: "Build Configurations:", string: self.content)
        let schemes = self.getGrouped(groupName: "Schemes:", string: self.content)
        
        return (projectName, targets, buildConfigurations, schemes)
    }
    
    private func getProjectName(firstLine: String) -> String {
        let regex = try? NSRegularExpression.init(pattern: "\\\"([A-Za-z-\\s]+)\\\"")
        if let match = regex?.firstMatch(in: firstLine, options: .reportCompletion, range: NSRange.init(location: 0, length: firstLine.count)) {
            return extract(from: firstLine, match: match)
        }
        return ""
    }
    
    private func getGrouped(groupName: String, string: String) -> [String] {
        let regex = try? NSRegularExpression.init(pattern: "\(groupName)(\\s+[A-Za-z-_]+)+(\\n\\n|$)")
        if let match = regex?.firstMatch(in: string, options: .reportCompletion, range: NSRange.init(location: 0, length: string.count)) {
            let values = extract(from: string, match: match).split(separator: "\n").map({String.init($0)})
            if values.count > 1 {
                return Array.init(values.suffix(from: 1)).map({$0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)})
            }
        }
        return []
    }
}
