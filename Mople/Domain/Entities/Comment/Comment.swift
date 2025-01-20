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
    var comment: String?
    var createdDate: Date?
}
