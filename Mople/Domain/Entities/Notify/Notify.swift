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
    let meetImgPath: String? = "https://picsum.photos/id/1/200/300"
    let meetTitle: String? = "모임 제목"
    let postDate: Date = DateManager.getPreviousMonth(Date())
    let type: NotifyType?
    let payload: NotifyPayload?
    var isNew: Bool = false
}
