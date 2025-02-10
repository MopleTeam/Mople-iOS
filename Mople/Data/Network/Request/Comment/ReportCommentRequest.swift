//
//  ReportComment.swift
//  Mople
//
//  Created by CatSlave on 2/2/25.
//

import Foundation

struct ReportCommentRequest: Encodable {
    let commentId: Int
    let comment: String
    
    enum CodingKeys: String, CodingKey {
        case commentId
        case comment = "reason"
    }
}
