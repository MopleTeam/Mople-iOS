//
//  Page.swift
//  Mople
//
//  Created by CatSlave on 7/11/25.
//

import Foundation

struct Page<T> {
    var totalCount: Int = 0
    var content: [T]
    var info: PageInfo?
}

struct PageInfo: Hashable {
    let nextCursor: String?
    let hasNext: Bool
    let size: Int
}
