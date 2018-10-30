//
//  CannonList.swift
//  buildcannon
//
//  Created by Anderson Lucas C. Ramos on 30/10/18.
//  Copyright © 2018 InsaniTech. All rights reserved.
//

import Foundation

class CannonList: ExecutorProtocol {
    weak var delegate: ExecutorCompletionProtocol?
    
    required init() { }
    
    func execute() {
        if let names = CannonFileLoader.init().listFilesNames(wasSourceCopied: false) {
            Console.log(message: "Available targets:")
            names.forEach({
                Console.log(message: "  - \($0)")
            })
            
            self.delegate?.executorDidFinishWithSuccess(self)
        } else {
            self.delegate?.executor(self, didFailWithErrorCode: -1)
        }
    }
    
    func cancel() {
        // nothing to do
    }
}
