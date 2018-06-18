//
//  TerminalMenuOption.swift
//  buildcannon
//
//  Created by Anderson Lucas C. Ramos on 13/06/18.
//  Copyright © 2018 InsaniTech. All rights reserved.
//

import Foundation

struct ActionMenuOption {
    let command: String
    let detail: String
    let action: os_block_t
    
    init(command: String, detail: String, action: @escaping os_block_t) {
        self.command = command
        self.detail = detail
        self.action = action
    }
}
