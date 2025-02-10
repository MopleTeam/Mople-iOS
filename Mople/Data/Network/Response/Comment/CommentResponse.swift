//
//  CommentResponse.swift
//  Mople
//
//  Created by CatSlave on 1/20/25.
//

import Foundation

struct CommentResponse: Decodable {
    let commentId: Int?
    let writerId: Int
    let writerName: String?
    let writerImage: String?
    let content: String?
    let time: String?
}

extension CommentResponse {
    func toDomain() -> Comment {
        let date = DateManager.parseServerDate(string: self.time)
        
        return .init(id: commentId,
                     writerId: writerId,
                     writerName: writerName,
                     writerThumbnailPath: writerImage,
                     comment: content,
                     createdDate: date)
    }
}
