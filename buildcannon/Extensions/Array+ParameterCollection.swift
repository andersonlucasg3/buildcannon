//
//  Array+ParameterCollection.swift
//  buildcannon
//
//  Created by Anderson Lucas C. Ramos on 13/06/18.
//  Copyright © 2018 InsaniTech. All rights reserved.
//

import Foundation

extension Array where Element == CommandParameter {
    fileprivate static let separator = "="
    
    static func from(arguments: [String]) -> [CommandParameter] {
        var parameters = Array<CommandParameter>()
        for arg in arguments.enumerated() {
            if arg.offset + 1 == arguments.count { break }
            if self.checkDoubleDash(arguments, arg.offset + 1, &parameters) {
                continue
            } else {
                if self.checkSingleDash(arguments, arg.offset + 1, &parameters) {
                    continue
                } else if self.checkNoDash(arguments, arg.offset + 1, &parameters) {
                    continue
                }
            }
        }
        return parameters
    }
    
    fileprivate static func build(_ arguments: [String], _ index: Int, _ output: inout Array<CommandParameter>, buildBlock: (String, String?) -> CommandParameter) -> Bool {
        let previousCount = output.count
        let parts = arguments[index].split(separator: "=")
        if parts.count > 1 {
            if let first = parts.first, let last = parts.last {
                output.append(buildBlock(String.init(first), String.init(last)))
            }
        } else {
            if let first = parts.first {
                output.append(buildBlock(String.init(first), nil))
            }
        }
        return previousCount != output.count
    }
    
    fileprivate static func checkSingleDash(_ arguments: [String], _ index: Int, _ output: inout Array<CommandParameter>) -> Bool {
        return arguments[index].hasPrefix("-") && self.buildSingleDash(arguments, index, &output)
    }
    
    fileprivate static func buildSingleDash(_ arguments: [String], _ index: Int, _ output: inout Array<CommandParameter>) -> Bool {
        return self.build(arguments, index, &output) { (first, last) -> CommandParameter in
            if let last = last {
                return SingleDashComplexParameter.init(parameter: first, composition: last, separator: self.separator)
            }
            return SingleDashParameter.init(parameter: first)
        }
    }
    
    fileprivate static func checkDoubleDash(_ arguments: [String], _ index: Int, _ output: inout Array<CommandParameter>) -> Bool {
        return arguments[index].hasPrefix("--") && self.buildDoubleDash(arguments, index, &output)
    }
    
    fileprivate static func buildDoubleDash(_ arguments: [String], _ index: Int, _ output: inout Array<CommandParameter>) -> Bool {
        return self.build(arguments, index, &output) { (first, last) -> CommandParameter in
            if let last = last {
                return DoubleDashComplexParameter.init(parameter: first, composition: last, separator: self.separator)
            }
            return DoubleDashParameter.init(parameter: first)
        }
    }
    
    fileprivate static func checkNoDash(_ arguments: [String], _ index: Int, _ output: inout Array<CommandParameter>) -> Bool {
        return !arguments[index].hasPrefix("--") && !arguments[index].hasPrefix("-") &&
            self.buildNoDash(arguments, index, &output)
    }
    
    fileprivate static func buildNoDash(_ arguments: [String], _ index: Int, _ output: inout Array<CommandParameter>) -> Bool {
        return self.build(arguments, index, &output) { (first, last) -> CommandParameter in
            if let last = last {
                return NoDashComplexParameter.init(parameter: first, composition: last, separator: self.separator)
            }
            return NoDashParameter.init(parameter: first)
        }
    }
}
