//
//  NoDashParameter.swift
//  buildcannon
//
//  Created by Anderson Lucas C. Ramos on 13/06/18.
//  Copyright © 2018 InsaniTech. All rights reserved.
//

import Foundation

class NoDashParameter: SingleDashParameter {
    override init(parameter: String) {
        super.init(parameter: parameter)
    }
    
    override func buildParameter() -> String {
        return self.parameter
    }
}
