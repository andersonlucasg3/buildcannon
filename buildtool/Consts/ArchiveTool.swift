//
//  ArchiveTool.swift
//  buildtool
//
//  Created by Anderson Lucas C. Ramos on 15/06/18.
//  Copyright © 2018 InsaniTech. All rights reserved.
//

import Foundation

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
