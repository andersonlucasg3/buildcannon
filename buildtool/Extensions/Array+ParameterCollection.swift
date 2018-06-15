//
//  Array+ParameterCollection.swift
//  buildtool
//
//  Created by Anderson Lucas C. Ramos on 13/06/18.
//  Copyright © 2018 InsaniTech. All rights reserved.
//

import Foundation

extension Array where Element == CommandParameter {
    static func fromArgs() -> [CommandParameter] {
        let current = ProcessInfo.processInfo
        
        var parameters = Array<CommandParameter>()
        for arg in current.arguments.enumerated() {
            if arg.offset + 1 == current.arguments.count { break }
            if self.checkDoubleDash(current.arguments, arg.offset + 1, &parameters) {
                continue
            } else {
                if self.checkSingleDash(current.arguments, arg.offset + 1, &parameters) {
                    continue
                } else {
                    continue
                }
            }
        }
        return parameters
    }
    
    fileprivate static func checkSingleDash(_ arguments: [String], _ index: Int, _ output: inout Array<CommandParameter>) -> Bool {
        return arguments[index].hasPrefix("-") && self.buildSingleDash(arguments, index, &output)
    }
    
    fileprivate static func buildSingleDash(_ arguments: [String], _ index: Int, _ output: inout Array<CommandParameter>) -> Bool {
        let nextIndex = index + 1
        if nextIndex < arguments.count {
            if !arguments[nextIndex].hasPrefix("--") && !arguments[nextIndex].hasPrefix("-") {
                output.append(SingleDashComplexParameter.init(parameter: arguments[index], composition: arguments[nextIndex]))
            } else {
                output.append(SingleDashParameter.init(parameter: arguments[index]))
            }
        } else {
            output.append(SingleDashParameter.init(parameter: arguments[index]))
        }
        return true
    }
    
    fileprivate static func checkDoubleDash(_ arguments: [String], _ index: Int, _ output: inout Array<CommandParameter>) -> Bool {
        return arguments[index].hasPrefix("--") && self.buildDoubleDash(arguments, index, &output)
    }
    
    fileprivate static func buildDoubleDash(_ arguments: [String], _ index: Int, _ output: inout Array<CommandParameter>) -> Bool {
        let nextIndex = index + 1
        if nextIndex < arguments.count {
            if !arguments[nextIndex].hasPrefix("--") && !arguments[nextIndex].hasPrefix("-") {
                output.append(DoubleDashComplexParameter.init(parameter: arguments[index], composition: arguments[nextIndex]))
            } else {
                output.append(DoubleDashParameter.init(parameter: arguments[index]))
            }
        } else {
            output.append(DoubleDashParameter.init(parameter: arguments[index]))
        }
        return true
    }
}
