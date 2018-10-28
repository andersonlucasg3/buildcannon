//
//  TerminalMenu.swift
//  buildcannon
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
            Console.log(message: "  \(option.command)\n      * \(option.detail)")
        }
        Console.log(message: "\n")
    }
}
