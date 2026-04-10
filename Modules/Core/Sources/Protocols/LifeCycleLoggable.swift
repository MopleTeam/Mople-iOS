//
//  LifeCycleLoggable.swift
//  Mople
//
//  Created by CatSlave on 1/11/25.
//

import Foundation

protocol LifeCycleLoggable {
    func logLifeCycle(function: String, line: Int)
}

extension LifeCycleLoggable {
    func logLifeCycle(function: String = #function, line: Int = #line) {
        #if DEBUG
        let className = String(describing: type(of: self))
        print("[\(className)] \(function):\(line)")
        #endif
    }
}

