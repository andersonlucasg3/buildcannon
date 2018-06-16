//
//  UploadTool.swift
//  buildcannon
//
//  Created by Anderson Lucas C. Ramos on 15/06/18.
//  Copyright © 2018 InsaniTech. All rights reserved.
//

import Foundation


struct UploadTool {
    static let toolPath = "\"/Applications/Xcode.app/Contents/Applications/Application Loader.app/Contents/Frameworks/ITunesSoftwareService.framework/Support/\""
    static let toolName = "altool"
    
    struct Parameters {
        static let uploadApp = "upload-app"
        static let file = "f"
        static let username = "u"
        static let password = "p"
    }
    
    struct Values {
        static let uploadLogPath = baseTempDir + "/uploadIpa.log"
    }
}
