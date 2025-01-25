//
//  Comment.swift
//  Group
//
//  Created by CatSlave on 11/5/24.
//

import Foundation

struct Comment: Hashable, Equatable {
    var id: Int?
    var writerId: Int?
    var writerName: String?
    var writerThumbnailPath: String?
    var comment: String?
    var createdDate: Date?
    var isWriter: Bool = false
    
    static func < (lhs: Comment, rhs: Comment) -> Bool {
        guard let lhsDate = lhs.createdDate,
              let rhsDate = rhs.createdDate else { return false }
        
        return lhsDate < rhsDate
    }
}

extension Comment {
    mutating func verifyWriter(_ userId: Int?) {
        guard let writerId,
              let userId else { return }
        isWriter = writerId == userId
    }
}
