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
        print(self.description)
        print()
        self.options.forEach { (option) in
            print("\t", "\(option.command)\n\t\t* \(option.detail)\n")
        }
        print()
    }
}
