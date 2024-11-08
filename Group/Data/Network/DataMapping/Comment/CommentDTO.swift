//
//  CommentResponseDTO.swift
//  Group
//
//  Created by CatSlave on 11/5/24.
//

import Foundation

struct CommentDTO: Decodable {
    var id: Int?
    var writerId: Int?
    var writerName: String?
    var writerThumbnailPath: String?
    var comment: String?
    var createdDate: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case writerId = "creatorId"
        case writerName = "creatorNickname"
        case writerThumbnailPath = "creatorProfileImgUrl"
        case comment = "contents"
        case createdDate = "createdAt"
    }
}

extension CommentDTO {
    func toDomain() -> Comment {
        return .init(id: id,
                     writerId: writerId,
                     writerName: writerName,
                     writerThumbnailPath: writerThumbnailPath,
                     commnet: comment,
                     createdDate: createdDate)

    }
}


