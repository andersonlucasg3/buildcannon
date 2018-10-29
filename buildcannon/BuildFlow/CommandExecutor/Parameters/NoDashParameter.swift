//
//  NoDashParameter.swift
//  buildcannon
//
//  Created by Anderson Lucas C. Ramos on 13/06/18.
//  Copyright © 2018 InsaniTech. All rights reserved.
//

import Foundation

class NoDashParameter: SingleDashParameter {
    required init(parameter: String) {
        super.init(parameter: parameter)
    }
    
    override func buildParameter() -> String {
        return self.parameter
    }
}

class NoDashComplexParameter: NoDashParameter, CommandComplexParameter {
    let composition: String
    
    required init(parameter: String) {
        self.composition = ""
        super.init(parameter: parameter)
    }
    
    required init(parameter: String, composition: String, separator: String) {
        self.composition = composition
        super.init(parameter: parameter)
    }
    
    override func buildParameter() -> String {
        return "\(self.parameter) \(self.composition)"
    }
}
