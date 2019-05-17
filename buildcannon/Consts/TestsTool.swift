//
//  TestsTool.swift
//  buildcannon
//
//  Created by Anderson Lucas C. Ramos on 17/05/19.
//  Copyright © 2019 InsaniTech. All rights reserved.
//

import Foundation

struct TestTool {
    static let toolPath = "/usr/bin/"
    static let toolName = "xcodebuild"
    
    struct Parameters {
        static let testParam = "test"
        static let cleanParam = "clean"
        static let workspaceParam = "workspace"
        static let projectParam = "project"
        static let targetParam = "target"
        static let schemeParam = "scheme"
        static let sdkParam = "sdk"
        static let destinationParam = "destination"
        static let useModernBuildSystem = "UseModernBuildSystem"
    }
    
    struct Values {
        static func testsLogPath(platform: String, osVersion: String) -> String {
            return baseTempDir + "/xcodebuildTests_\(platform)_\(osVersion).log"
        }
        
        static let sdkConfig = "iphoneos"
    }
}
