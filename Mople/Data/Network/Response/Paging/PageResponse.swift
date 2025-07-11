//
//  PageResponse.swift
//  Mople
//
//  Created by CatSlave on 7/11/25.
//

import Foundation

// MARK: - CursorPage Model
struct PageResponse: Decodable {
    let nextCursor: String?
    let hasNext: Bool
    let size: Int
}

extension PageResponse {
    func toDomain() -> PageInfo {
        return .init(nextCursor: nextCursor,
                     hasNext: hasNext,
                     size: size)
    }
}
