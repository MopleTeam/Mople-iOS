//
//  Notify.swift
//  Mople
//
//  Created by CatSlave on 4/10/25.
//

import Foundation

public enum NotifyType {
    case meet(id: Int)
    case plan(id: Int, date: Date?)
    case review(id: Int)
}

public struct Notify {
    public let id: Int?
    public let meetImgPath: String?
    public let meetTitle: String?
    public let receiveDate: Date?
    public let type: NotifyType?
    public let message: String?
    public var isRead: Bool = false

    public init(id: Int? = nil, meetImgPath: String? = nil, meetTitle: String? = nil, receiveDate: Date? = nil, type: NotifyType? = nil, message: String? = nil, isRead: Bool = false) {
        self.id = id
        self.meetImgPath = meetImgPath
        self.meetTitle = meetTitle
        self.receiveDate = receiveDate
        self.type = type
        self.message = message
        self.isRead = isRead
    }
}
