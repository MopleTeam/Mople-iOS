//
//  CommentMock.swift
//  Mople
//
//  Created by CatSlave on 1/20/25.
//

import Foundation

extension Comment {
    static func mock() -> Comment {
        return Comment(id: 1,
                       writerId: 1,
                       writerName: "동주",
                       writerThumbnailPath: "https://picsum.photos/id/1/200/300",
                       comment: "안녕",
                       createdDate: Date())
    }
}
