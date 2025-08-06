//
//  CommentViewModel.swift
//  Mople
//
//  Created by CatSlave on 7/23/25.
//

import Foundation

struct CommentViewModel {
    var type: CommentType
    var writerName: String?
    var writerThumbnailPath: String?
    var text: String?
    var writedDate: Date?
    var isLiked: Bool = false
    var likeCount: Int = 0
    
    var commentDate: String? {
        guard let writedDate else { return nil }
        return writedDate.timeAgoDescription()
    }
}

extension CommentViewModel {
    init(_ comment: Comment) {
        self.type = comment.type
        self.writerName = comment.writerName ?? L10n.nonName
        self.writerThumbnailPath = comment.writerThumbnailPath
        self.text = comment.comment
        self.writedDate = comment.createdDate
        self.isLiked = comment.isLiked
        self.likeCount = comment.likeCount
    }
}
