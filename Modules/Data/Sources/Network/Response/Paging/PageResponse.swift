//
//  PageResponse.swift
//  Mople
//
//  Created by CatSlave on 7/11/25.
//

import Foundation
import Domain

struct PageResponse<T: Decodable>: Decodable {
    var totalCount: Int?
    var content: [T]
    var page: PageInfoResponse?
}

// MARK: - CursorPage Model
struct PageInfoResponse: Decodable {
    let nextCursor: String?
    let hasNext: Bool
    let size: Int
}

extension PageInfoResponse {
    func toDomain() -> PageInfo {
        return .init(nextCursor: nextCursor,
                     hasNext: hasNext,
                     size: size)
    }
}
