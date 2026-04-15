//
//  DebugPrint.swift
//  Data
//

import Foundation

public func printIfDebug(_ string: String) {
    #if DEBUG
    print(string)
    #endif
}
