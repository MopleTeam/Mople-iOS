//
//  CommentListSectionModel.swift
//  Mople
//
//  Created by CatSlave on 1/24/25.
//

import UIKit
import Differentiator

enum SectionItem {
    case photo([UIImage])
    case comment(Comment)
}

enum SectionType {
    case photoList
    case commentList
    
    var title: String {
        switch self {
        case .photoList:
            return L10n.Review.photoHeader
        case .commentList:
            return L10n.comment
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
