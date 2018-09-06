//
//  CannonFileTargetCreator.swift
//  buildcannon
//
//  Created by Anderson Lucas C. Ramos on 06/09/18.
//  Copyright © 2018 InsaniTech. All rights reserved.
//

import Foundation

class CannonFileTargetCreator: CannonFileCreator {
    override func cannonFileName(target: String) -> String {
        return "\(target).cannon"
    }
}
