//
//  Collection+UniqueAndSort.swift
//  Mople
//
//  Created by CatSlave on 8/19/25.
//

import Foundation

public extension Array where Element: Hashable & Comparable {
    mutating func uniqueSorted() {
        var unique = Set(self)
        self = Array(unique).sorted(by: <)
    }
}
