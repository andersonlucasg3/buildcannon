//
//  ExportTool.swift
//  buildcannon
//
//  Created by Anderson Lucas C. Ramos on 15/06/18.
//  Copyright © 2018 InsaniTech. All rights reserved.
//

import Foundation

struct ExportTool {
    static let toolPath = "/usr/bin/"
    static let toolName = "xcodebuild"
    
    struct Parameters {
        static let exportArchive = "exportArchive"
        static let archivePath = "archivePath"
        static let exportOptionsPlistPath = "exportOptionsPlist"
        static let exportPath = "exportPath"
        static let allowProvisioningUpdates = "allowProvisioningUpdates"
    }
    
    struct Values {
        static let exportLogPath = baseTempDir + "/exportIpa.log"
        static let exportPlistPath = baseTempDir + "/exportOptions.plist"
        static let exportPath = baseTempDir
    }
}
