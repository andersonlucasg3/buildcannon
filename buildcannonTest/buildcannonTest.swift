//
//  buildcannonTest.swift
//  buildcannonTest
//
//  Created by Anderson Lucas C. Ramos on 27/10/18.
//  Copyright © 2018 InsaniTech. All rights reserved.
//

import XCTest

class buildcannonTest: XCTestCase {
    func testInputParameterConstructions() {
        let args = [
            "buildcannon",
            "distribute",
            "--param1=shit1",
            "-param2=shit2",
            "--param3",
            "-param4",
            "crazy",
            "crazy1=shit3"
        ]
        let inputParams: Array<CommandParameter> = Array<CommandParameter>.from(arguments: args)
        
        let noDashParameter = inputParams[0] as! NoDashParameter
        let doubleDashComplexParameter = inputParams[1] as! DoubleDashComplexParameter
        let singleDashComplexParameter = inputParams[2] as! SingleDashComplexParameter
        let doubleDashParameter = inputParams[3] as! DoubleDashParameter
        let singleDashParameter = inputParams[4] as! SingleDashParameter
        let lastNoDashParameter = inputParams[5] as! NoDashParameter
        let lastNoDashComplexParameter = inputParams[6] as! NoDashComplexParameter
        assert(noDashParameter.parameter == "distribute")
        assert(doubleDashComplexParameter.parameter == "param1" && doubleDashComplexParameter.composition == "shit1")
        assert(singleDashComplexParameter.parameter == "param2" && singleDashComplexParameter.composition == "shit2")
        assert(doubleDashParameter.parameter == "param3")
        assert(singleDashParameter.parameter == "param4")
        assert(lastNoDashParameter.parameter == "crazy")
        assert(lastNoDashComplexParameter.parameter == "crazy1" && lastNoDashComplexParameter.composition == "shit3")
    }
}
