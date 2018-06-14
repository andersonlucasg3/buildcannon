//
//  TerminalMenu.swift
//  buildtool
//
//  Created by Anderson Lucas C. Ramos on 13/06/18.
//  Copyright © 2018 Anderson Lucas C. Ramos. All rights reserved.
//

import Foundation

struct ActionMenu {
    let description: String
    let options: Array<ActionMenuOption>
    
    init(description: String, options: [ActionMenuOption]) {
        self.description = description
        self.options = options
    }
    
    func draw() {
        Logger.log(message: self.description)
        Logger.log(message: "\n")
        self.options.forEach { (option) in
            Logger.log(message: "\t\(option.command)\n\t\t* \(option.detail)\n")
        }
        Logger.log(message: "\n")
    }
}
