//
//  main.swift
//  buildtool
//
//  Created by Anderson Lucas C. Ramos on 13/06/18.
//  Copyright © 2018 Anderson Lucas C. Ramos. All rights reserved.
//

import Foundation
import Dispatch

let application = Application.init()
signal(SIGINT, SIG_IGN)
let source = DispatchSource.makeSignalSource(signal: SIGINT, queue: .main)
source.setEventHandler {
    application.interrupt()
    exit(0)
}
source.resume()
application.start()
