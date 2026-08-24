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

public extension Meet {
    // pinnedNotice는 let 이라 부분 갱신 불가 — copy with replacement 헬퍼.
    // 공지 핀 토글 알림 수신 시 모임상세 상태를 새 인스턴스로 갱신할 때 사용.
    func with(pinnedNotice: Notice?) -> Meet {
        return Meet(
            isCreator: isCreator,
            meetSummary: meetSummary,
            sinceDays: sinceDays,
            creatorId: creatorId,
            memberCount: memberCount,
            firstPlanDate: firstPlanDate,
            version: version,
            pinnedNotice: pinnedNotice
        )
    }
}
