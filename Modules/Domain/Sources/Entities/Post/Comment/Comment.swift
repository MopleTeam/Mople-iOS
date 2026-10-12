//
//  Comment.swift
//  Group
//
//  Created by CatSlave on 11/5/24.
//

import Foundation

public enum CommentType {
    case parent
    case child
}

public struct Comment: Hashable, Comparable {

    public var uuid = UUID()
    public var isMockup: Bool = false
    public var isLoading: Bool = false
    public var id: Int?
    public var postId: Int?
    public var parentId: Int?
    public var writerId: Int?
    public var writerName: String?
    public var writerThumbnailPath: String?
    public var comment: String?
    public var createdDate: Date?
    public var isWriter: Bool = false
    public var isLiked: Bool = false
    public var likeCount: Int = 0
    public var replyCount: Int = 0
    public var mentions: [UserInfo] = []

    public init(uuid: UUID = UUID(), isMockup: Bool = false, isLoading: Bool = false, id: Int? = nil, postId: Int? = nil, parentId: Int? = nil, writerId: Int? = nil, writerName: String? = nil, writerThumbnailPath: String? = nil, comment: String? = nil, createdDate: Date? = nil, isWriter: Bool = false, isLiked: Bool = false, likeCount: Int = 0, replyCount: Int = 0, mentions: [UserInfo] = []) {
        self.uuid = uuid
        self.isMockup = isMockup
        self.isLoading = isLoading
        self.id = id
        self.postId = postId
        self.parentId = parentId
        self.writerId = writerId
        self.writerName = writerName
        self.writerThumbnailPath = writerThumbnailPath
        self.comment = comment
        self.createdDate = createdDate
        self.isWriter = isWriter
        self.isLiked = isLiked
        self.likeCount = likeCount
        self.replyCount = replyCount
        self.mentions = mentions
    }

    public var type: CommentType {
        return parentId == nil ? .parent : .child
    }

    public static func < (lhs: Comment, rhs: Comment) -> Bool {
        guard let lhsDate = lhs.createdDate,
              let rhsDate = rhs.createdDate else { return false }
        
        return lhsDate < rhsDate
    }
}

public extension Comment {
    public mutating func verifyWriter(_ userId: Int?) {
        guard let writerId,
              let userId else { return }
        isWriter = writerId == userId
    }
    
    public mutating func replaceComment(_ comment: Comment) {
        self.isMockup = false
        self.comment = comment.comment
        self.likeCount = comment.likeCount
        self.isLiked = comment.isLiked
        self.replyCount = comment.replyCount
    }
    
    public mutating func updatePostId(postId: Int) {
        self.postId = postId
    }
}

public extension Comment {
    public static func mockComment() -> Self {
        return .init(isMockup: true)
    }
}
