//
//  CannonUpload.swift
//  buildcannon
//
//  Created by Anderson Lucas C. Ramos on 29/10/18.
//  Copyright © 2018 InsaniTech. All rights reserved.
//

import Foundation

class CannonUpload: CannonExport {
    override func execute() {
        if self.validateRequiredParameters(dependency: CannonParameter.upload.dependency) {
            self.executeUpload()
        } else {
            application.interrupt(code: -1)
        }
    }
    
    override func uploadExecutorDidFinishWithSuccess() {
        Console.log(message: "Upload finished with success")
    }
}
