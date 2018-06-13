//
//  NoDashParameter.swift
//  buildtool
//
//  Created by Anderson Lucas C. Ramos on 13/06/18.
//  Copyright © 2018 Anderson Lucas C. Ramos. All rights reserved.
//

import Foundation

class NoDashParameter: SingleDashParameter {
    override func buildParameter() -> String {
        return self.parameter
    }
}
