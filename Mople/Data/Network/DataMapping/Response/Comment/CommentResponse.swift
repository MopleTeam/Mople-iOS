//
//  CommentResponse.swift
//  Mople
//
//  Created by CatSlave on 1/20/25.
//

import Foundation

struct CommentResponse: Decodable {
    var commentId: Int?
    var writerId: Int
    var writerName: String?
    var writerImage: String?
    var content: String?
    var time: String?
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
