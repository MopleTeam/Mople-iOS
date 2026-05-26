//
//  NoticeCommentResponse.swift
//  Data
//
//  Created by CatSlave on 5/26/26.
//
//  서버 NoticeCommentClientResponse — 공지 댓글 객체.
//  Post 댓글과 달리 likes/replies/mentions 정보가 응답에 없어 Comment 도메인의 일부만 채운다.
//

import Foundation
import Domain

struct NoticeCommentResponse: Decodable {
    let commentId: Int?
    let version: Int?
    let content: String?
    let parentId: Int?
    let writer: UserInfoResponse?
    let time: String?
    let noticeId: Int?
}

extension NoticeCommentResponse {
    func toDomain() -> Comment {
        let date = DateManager.parseServerFullDate(string: time)
        return .init(id: commentId,
                     postId: noticeId,
                     parentId: parentId,
                     writerId: writer?.userId,
                     writerName: writer?.nickname,
                     writerThumbnailPath: writer?.image,
                     comment: content,
                     createdDate: date,
                     isLiked: false,
                     likeCount: 0,
                     replyCount: 0,
                     mentions: [])
    }
}
