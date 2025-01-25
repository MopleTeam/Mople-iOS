//
//  CommentListSectionModel.swift
//  Mople
//
//  Created by CatSlave on 1/24/25.
//

import UIKit
import Differentiator

enum SectionItem {
    case photo([String?])
    case comment(Comment)
}

enum SectionType {
    case photoList
    case commentList
    
    var title: String {
        switch self {
        case .photoList:
            return "함께한 순간"
        case .commentList:
            return "댓글"
        }
    }
    
    var height: CGFloat {
        switch self {
        case .photoList:
            return 157
        case .commentList:
            return UITableView.automaticDimension
        }
    }
}

struct CommentTableSectionModel: SectionModelType {
    let type: SectionType
    var items: [SectionItem] = []
}

extension CommentTableSectionModel {
    
    typealias Item = SectionItem
    
    init(original: CommentTableSectionModel, items: [SectionItem]) {
        self = original
        self.items = items
    }
}
