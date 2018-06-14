//
//  Consts.swift
//  buildtool
//
//  Created by Anderson Lucas C. Ramos on 13/06/18.
//  Copyright © 2018 Anderson Lucas C. Ramos. All rights reserved.
//

import Foundation

let baseTempDir = NSTemporaryDirectory() + UUID.init().uuidString

struct ArchiveTool {
    static let toolPath = "/usr/bin/"
    static let toolName = "xcodebuild"
    
    struct Parameters {
        static let workspaceParam = "workspace"
        static let projectParam = "project"
        static let schemeParam = "scheme"
        static let sdkParam = "sdk"
        static let configurationParam = "configuration"
        static let archiveParam = "archive"
        static let archivePathParam = "archivePath"
    }
    
    struct Values {
        static let sdkConfig = "iphoneos"
        static let configurationConfig = "AppStoreDistribution"
        static let archivePath = baseTempDir + "/app.xcarchive"
        static let archiveLogPath = baseTempDir + "/archive.log"
    }
}

struct ExportTool {
    static let exportFileName = "exportOptions.plist"
}

struct UploadTool {
    static let path = "/Applications/Xcode.app/Contents/Applications/Application Loader.app/Contents/Frameworks/ITunesSoftwareService.framework/Support/"
    static let name = "altool"
}

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
