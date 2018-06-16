//
//  ExecutorProtocol.swift
//  buildcannon
//
//  Created by Anderson Lucas C. Ramos on 15/06/18.
//  Copyright © 2018 InsaniTech. All rights reserved.
//

import Foundation

protocol ExecutorProtocol: class {
    func execute()
    func cancel()
}
