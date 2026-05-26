//
//  PinnedNotice.swift
//  Domain
//
//  Created by CatSlave on 5/26/26.
//

import Foundation

// MeetDetail 응답에 포함되는 상단 고정 공지. nil이면 표시할 공지 없음.
public struct PinnedNotice {
    public let noticeId: Int?
    public let version: Int?
    public let meetId: Int?
    public let type: NoticeType?
    public let content: String?
    public let isPinned: Bool
    public let createdAt: Date?

    public init(noticeId: Int? = nil,
                version: Int? = nil,
                meetId: Int? = nil,
                type: NoticeType? = nil,
                content: String? = nil,
                isPinned: Bool = false,
                createdAt: Date? = nil) {
        self.noticeId = noticeId
        self.version = version
        self.meetId = meetId
        self.type = type
        self.content = content
        self.isPinned = isPinned
        self.createdAt = createdAt
    }
}
