//
//  Notify.swift
//  Mople
//
//  Created by CatSlave on 4/10/25.
//

import Foundation

enum NotifyType {
    case meet(id: Int)
    case plan(id: Int)
    case review(id: Int)
}

struct Notify {
    let id: Int?
    let meetImgPath: String?
    let meetTitle: String? 
    let postDate: Date?
    let type: NotifyType?
    let payload: NotifyPayload?
    var isNew: Bool = false
}
