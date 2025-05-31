//
//  CommentTableCellModel.swift
//  Mople
//
//  Created by CatSlave on 1/20/25.
//

import Foundation

struct CommentTableCellModel {
    var id: Int?
    var writerId: Int?
    var writerName: String?
    var writerImagePath: String?
    var comment: String?
    var isLastComment: Bool
    private var writedDate: Date?
    
    var commentDate: String? {
        guard let writedDate else { return nil }
        return writedDate.timeAgoDescription()
    }
}

extension CommentTableCellModel {
    init(_ comment: Comment,
         isLast: Bool) {
        self.id = comment.id
        self.writerId = comment.writerId
        self.writerName = comment.writerName ?? L10n.nonName
        self.writerImagePath = comment.writerThumbnailPath
        self.writedDate = comment.createdDate
        self.comment = comment.comment
        self.isLastComment = isLast
    }
}
