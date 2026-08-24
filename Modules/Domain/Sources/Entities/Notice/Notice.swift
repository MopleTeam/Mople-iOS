//
//  Notice.swift
//  Domain
//
//  Created by CatSlave on 5/26/26.
//

import Foundation

// 모임 공지. MeetDetail 응답의 pinnedNotice, Notice 리스트 응답의 셀, 공지 상세 모두 같은 구조.
// isPinned 플래그로 고정 여부 표현.
public struct Notice: Hashable {
    public let noticeId: Int?
    public let version: Int?
    public let meetId: Int?
    public let type: NoticeType?
    public let content: String?
    public let writer: UserInfo?   // 공지 작성자 (백엔드 writer 응답)
    public let isPinned: Bool
    public let createdAt: Date?

    public init(noticeId: Int? = nil,
                version: Int? = nil,
                meetId: Int? = nil,
                type: NoticeType? = nil,
                content: String? = nil,
                writer: UserInfo? = nil,
                isPinned: Bool = false,
                createdAt: Date? = nil) {
        self.noticeId = noticeId
        self.version = version
        self.meetId = meetId
        self.type = type
        self.content = content
        self.writer = writer
        self.isPinned = isPinned
        self.createdAt = createdAt
    }
}
