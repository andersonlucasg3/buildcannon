//
//  DoubleDashParameter.swift
//  buildtool
//
//  Created by Anderson Lucas C. Ramos on 13/06/18.
//  Copyright © 2018 Anderson Lucas C. Ramos. All rights reserved.
//

import Foundation

class DoubleDashParameter: CommandParameter {
    fileprivate(set) var parameter: String
    
    init(parameter: String) {
        self.parameter = parameter
        if self.parameter.hasPrefix("--") {
            self.parameter = String(self.parameter[self.parameter.index(self.parameter.startIndex, offsetBy: 2)..<self.parameter.endIndex])
        }
    }
    
    func buildParameter() -> String {
        return "--\(self.parameter)"
    }
}

class DoubleDashComplexParameter: DoubleDashParameter {
    fileprivate let separator: String
    
    let composition: String
    
    init(parameter: String, composition: String, separator: String = " ") {
        self.composition = composition
        self.separator = separator
        super.init(parameter: parameter)
    }
    
    override func buildParameter() -> String {
        return "\(super.buildParameter())\(self.separator)\(self.composition)"
    }
}
