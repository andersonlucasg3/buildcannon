//
//  TargetsProcessor.swift
//  buildcannon
//
//  Created by Anderson Lucas C. Ramos on 30/10/18.
//  Copyright © 2018 InsaniTech. All rights reserved.
//

import Foundation

class DistributeTargetsProcessor {
    fileprivate let parameters: [CommandParameter]
    
    init(_ parameters: [CommandParameter]) {
        self.parameters = parameters
    }
    
    func process() -> [String]? {
        if self.hasMinusAll() {
            return self.fetchAllTargets()
        }
        return self.parseTargets()
    }
    
    fileprivate func fetchAllTargets() -> [String]? {
        return CannonFileLoader.init().listFilesNames()
    }
    
    fileprivate func hasMinusAll() -> Bool {
        return self.parameters.contains(where: { $0.parameter == InputParameter.Distribute.all.name })
    }
    
    fileprivate func parseTargets() -> [String]? {
        if let targets = self.parameters.first(where: {$0.parameter == InputParameter.Distribute.targets.name }) as? DoubleDashComplexParameter {
            return targets.composition.split(separator: ",").compactMap({ String.init($0) })
        }
        return nil
    }
}
