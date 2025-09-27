//
//  CommentResponse.swift
//  Mople
//
//  Created by CatSlave on 1/20/25.
//

import Foundation

// MARK: - Comment Model
struct CommentResponse: Decodable {
    let commentId: Int
    let content: String
    let postId: Int
    let parentId: Int?
    let replyCount: Int?
    let likeCount: Int
    let likedByMe: Bool
    let mentions: [UserInfoResponse]
    let time: String
    let writer: UserInfoResponse
}

extension CommentResponse {
    func toDomain() -> Comment {
        let date = DateManager.parseServerFullDate(string: self.time)
        let domainMentions = mentions.map { $0.toDomain() }
        return .init(id: commentId,
                     parentId: parentId,
                     writerId: writer.userId,
                     writerName: writer.nickname,
                     writerThumbnailPath: writer.image,
                     comment: content,
                     createdDate: date,
                     isLiked: likedByMe,
                     likeCount: likeCount,
                     replyCount: replyCount ?? 0,
                     mentions: domainMentions)
    }
}


