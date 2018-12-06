//
//  main.swift
//  buildcannon
//
//  Created by Anderson Lucas C. Ramos on 13/06/18.
//  Copyright © 2018 InsaniTech. All rights reserved.
//

import Foundation

let application = Application.init()
Trap.handle(signal: .interrupt) { value in
    application.sourceCodeManager.deleteSourceCode()
    application.interrupt(code: Int(value))
}
application.start()
