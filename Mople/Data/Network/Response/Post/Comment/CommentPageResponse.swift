//
//  CommentResponse.swift
//  Mople
//
//  Created by CatSlave on 1/20/25.
//

import Foundation

// MARK: - Main Response Model
struct CommentPageResponse: Decodable {
    let content: [CommentResponse]
    let cursorPage: PageResponse
}

extension CommentPageResponse {
    func toDomain() -> CommentPage {
        let content = content.map { $0.toDomain() }
        let pageInfo = cursorPage.toDomain()
        return .init(content: content,
                     page: pageInfo)
    }
}

// MARK: - Comment Model
struct CommentResponse: Decodable {
    let commentId: Int
    let content: String
    let postId: Int
    let parentId: Int?
    let replyCount: Int
    let likeCount: Int
    let likedByMe: Bool
    let time: String
    let writer: UserInfoResponse
}

extension CommentResponse {
    func toDomain() -> Comment {
        let date = DateManager.parseServerFullDate(string: self.time)
        
        return .init(id: commentId,
                     writerId: writer.userId,
                     writerName: writer.nickname,
                     writerThumbnailPath: writer.image,
                     comment: content,
                     createdDate: date)
    }
}


