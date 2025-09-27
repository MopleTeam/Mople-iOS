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

struct Comment: Hashable, Comparable {

    var uuid = UUID()
    var isMockup: Bool = false
    var isLoading: Bool = false
    var id: Int?
    var postId: Int?
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
    var mentions: [UserInfo] = []
    
    var type: CommentType {
        return parentId == nil ? .parent : .child
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
    
    mutating func updatePostId(postId: Int) {
        self.postId = postId
    }
}

extension Comment {
    static func mockComment() -> Self {
        return .init(isMockup: true)
    }
}
