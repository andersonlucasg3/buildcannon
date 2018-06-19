//
//  ExecutorProtocol.swift
//  buildcannon
//
//  Created by Anderson Lucas C. Ramos on 15/06/18.
//  Copyright © 2018 InsaniTech. All rights reserved.
//

import Foundation

protocol ExecutorCompletionProtocol: class {
    func executorDidFinishWithSuccess(_ executor: ExecutorProtocol)
    func executor(_ executor: ExecutorProtocol, didFailWithErrorCode code: Int)
}

protocol ExecutorProtocol: class {
    var delegate: ExecutorCompletionProtocol? { get set }
    
    func execute()
    func cancel()
    
    init()
}
