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
        let betweenCount = DateManager.numberOfTimeBetween(writedDate)
        
        let components = [
            (betweenCount.year, "년"),
            (betweenCount.month, "개월"),
            (betweenCount.day, "일"),
            (betweenCount.hour, "시간"),
            (betweenCount.minute, "분"),
            (betweenCount.second, "초")
        ]
        
        guard let (value, unit) = components.first(where: { $0.0 != 0 }),
              let value else { return "1초 전" }
        
        return "\(abs(value))\(unit) 전"
    }
}

extension CommentTableCellModel {
    init(_ comment: Comment,
         isLast: Bool) {
        self.id = comment.id
        self.writerId = comment.writerId
        self.writerName = comment.writerName ?? "참여자"
        self.writerImagePath = comment.writerThumbnailPath
        self.writedDate = comment.createdDate
        self.comment = comment.comment
        self.isLastComment = isLast
    }
}
