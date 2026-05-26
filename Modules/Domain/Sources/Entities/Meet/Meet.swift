//
//  Meet.swift
//  Mople
//
//  Created by CatSlave on 12/16/24.
//

import Foundation

public struct Meet {
    public var isCreator: Bool = false
    public let meetSummary: MeetSummary?
    public let sinceDays: Int?
    public var creatorId: Int?
    public let memberCount: Int?
    public let firstPlanDate: Date?
    public let version: Int?
    public let pinnedNotice: Notice?

    public init(isCreator: Bool = false,
                meetSummary: MeetSummary? = nil,
                sinceDays: Int? = nil,
                creatorId: Int? = nil,
                memberCount: Int? = nil,
                firstPlanDate: Date? = nil,
                version: Int? = nil,
                pinnedNotice: Notice? = nil) {
        self.isCreator = isCreator
        self.meetSummary = meetSummary
        self.sinceDays = sinceDays
        self.creatorId = creatorId
        self.memberCount = memberCount
        self.firstPlanDate = firstPlanDate
        self.version = version
        self.pinnedNotice = pinnedNotice
    }
}
