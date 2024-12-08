//
//  Collection+SafeElement.swift
//  Mople
//
//  Created by CatSlave on 12/8/24.
//

import Foundation

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
