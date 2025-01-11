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
    var commnet: String?
    var createdDate: String?
    
    init(id: Int? = nil,
         writerId: Int? = nil,
         writerName: String? = nil,
         writerThumbnailPath: String? = nil,
         commnet: String? = nil,
         createdDate: String? = nil) {
        self.id = id
        self.writerId = writerId
        self.writerName = writerName
        self.writerThumbnailPath = writerThumbnailPath
        self.commnet = commnet
        self.createdDate = createdDate
    }
}
