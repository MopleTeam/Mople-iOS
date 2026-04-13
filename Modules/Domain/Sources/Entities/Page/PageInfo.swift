//
//  Page.swift
//  Mople
//
//  Created by CatSlave on 7/11/25.
//

import Foundation

public struct Page<T> {
    public var totalCount: Int = 0
    public var content: [T]
    public var info: PageInfo?

    public init(totalCount: Int = 0, content: [T], info: PageInfo? = nil) {
        self.totalCount = totalCount
        self.content = content
        self.info = info
    }
}

public struct PageInfo: Hashable {
    public let nextCursor: String?
    public let hasNext: Bool
    public let size: Int

    public init(nextCursor: String? = nil, hasNext: Bool, size: Int) {
        self.nextCursor = nextCursor
        self.hasNext = hasNext
        self.size = size
    }
}
