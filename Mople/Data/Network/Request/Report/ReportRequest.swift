//
//  ReportRequest.swift
//  Mople
//
//  Created by CatSlave on 2/14/25.
//

import Foundation

enum ReportType {
    case plan(id: Int)
    case review(id: Int)
    case comment(id: Int)
}

struct ReportRequest: Encodable {
    let type: ReportType
    let reason: String
    
    enum CodingKeys: String, CodingKey {
        case planId, reviewId, commentId, reason
    }
    
    func encode(to encoder: Encoder) throws {
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
