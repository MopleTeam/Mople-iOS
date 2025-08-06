//
//  Comment.swift
//  Group
//
//  Created by CatSlave on 11/5/24.
//

import Foundation

enum CommentType {
    case parent
    case child
}

struct CommentPage {
    var content: [Comment] = []
    var page: PageInfo?
}

struct Comment: Hashable, Comparable {
    
    // MARK: - UUID
    let uuid = UUID()
    
    // MARK: - 임시 댓글
    var isMockup: Bool = false
    
    // MARK: - 댓글 속성
    var id: Int?
    var parentId: Int?
    var writerId: Int?
    var writerName: String?
    var writerThumbnailPath: String?
    var comment: String?
    var createdDate: Date?
    var isWriter: Bool = false
    var isLiked: Bool = false
    var likeCount: Int = 0
    var replyCount: Int = 0
    var loadReplyCount: Int = 0
    var replyPage: PageInfo?
    var hasCachingReply: Bool = false
    
    var type: CommentType {
        return parentId == nil ? .parent : .child
    }
    
    var remainReplyCount: Int {
        return replyCount - loadReplyCount
    }
    
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
    
    mutating func replaceComment(_ comment: Comment) {
        self.isMockup = false
        self.comment = comment.comment
        self.likeCount = comment.likeCount
        self.isLiked = comment.isLiked
        self.replyCount = comment.replyCount
    }
}

extension Comment {
    static func mockComment(parentId: Int? = nil) -> Self {
        return .init(isMockup: true, parentId: parentId)
    }
}
