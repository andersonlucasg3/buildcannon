//
//  CommandParametersChecker.swift
//  buildtool
//
//  Created by Anderson Lucas C. Ramos on 13/06/18.
//  Copyright © 2018 Anderson Lucas C. Ramos. All rights reserved.
//

import Foundation

struct CommandParametersChecker {
    fileprivate let parameters: [CommandParameter]
    
    init(parameters: [CommandParameter]) {
        self.parameters = parameters
    }
    
    func checkParameters() -> Bool {
        var containsAllRequired = true
        Parameters.REQUIRED_PARAMETERS.forEach({ (item) in
            containsAllRequired = containsAllRequired && self.parameters.contains(where: {
                $0.parameter == item.name && type(of: $0) == item.type
            })
        })
        return containsAllRequired
    }
    
    func checkHelp() -> Bool {
        return self.parameters.contains(where: {$0.parameter == Parameters.help.name})
    }
}
