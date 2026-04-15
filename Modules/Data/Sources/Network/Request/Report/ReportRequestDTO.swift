//
//  ReportRequestDTO.swift
//  Mople
//
//  Created by CatSlave on 2/14/25.
//

import Foundation
import Domain

// MARK: - 신고 대상 유형 DTO
public enum ReportTypeDTO {
    case plan(id: Int)
    case review(id: Int)
    case comment(id: Int)
}

// MARK: - 신고 API 요청 DTO
public struct ReportRequestDTO: Encodable {
    public let type: ReportTypeDTO
    public let reason: String?

    enum CodingKeys: String, CodingKey {
        case planId, reviewId, commentId, reason
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(reason, forKey: .reason)

        switch type {
        case let .plan(id):
            try container.encode(id, forKey: .planId)
        case .review(let id):
            try container.encode(id, forKey: .reviewId)
        case .comment(let id):
            try container.encode(id, forKey: .commentId)
        }
    }
}

// MARK: - Domain → DTO 변환
extension ReportRequestDTO {
    init(request: ReportRequest) {
        switch request.type {
        case .plan(let id):
            self.type = .plan(id: id)
        case .review(let id):
            self.type = .review(id: id)
        case .comment(let id):
            self.type = .comment(id: id)
        }
        self.reason = request.reason
    }
}
