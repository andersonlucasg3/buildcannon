//
//  TerminalMenu.swift
//  buildtool
//
//  Created by Anderson Lucas C. Ramos on 13/06/18.
//  Copyright © 2018 InsaniTech. All rights reserved.
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
        Console.log(message: self.description)
        self.options.forEach { (option) in
            Console.log(message: "\t\(option.command)\n\t\t* \(option.detail)\n")
        }
        Console.log(message: "\n")
    }
}
