//
//  Notify.swift
//  Mople
//
//  Created by CatSlave on 4/10/25.
//

import Foundation

enum NotifyType {
    case meet(id: Int)
    case plan(id: Int, date: Date?)
    case review(id: Int)
}

struct Notify {
    let id: Int?
    let meetImgPath: String?
    let meetTitle: String? 
    let receiveDate: Date?
    let type: NotifyType?
    let message: String?
    var isRead: Bool = false
}
