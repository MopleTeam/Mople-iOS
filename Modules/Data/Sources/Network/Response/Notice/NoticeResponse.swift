//
//  NoticeResponse.swift
//  Data
//
//  Created by CatSlave on 5/26/26.
//
//  서버 NoticeClientResponse — 공지 객체 단일 표현.
//  MeetDetail 응답의 pinnedNotice 중첩 + 공지 리스트/상세 응답 모두 같은 구조.
//

import Foundation
import Domain

struct NoticeResponse: Decodable {
    let noticeId: Int?
    let version: Int?
    let meetId: Int?
    let type: String?
    let content: String?
    let pinned: Bool?
    let createdAt: String?
}

extension NoticeResponse {
    func toDomain() -> Notice {
        return .init(
            noticeId: noticeId,
            version: version,
            meetId: meetId,
            type: NoticeType(rawValue: type ?? ""),
            content: content,
            isPinned: pinned ?? false,
            createdAt: DateManager.parseServerFullDate(string: createdAt)
        )
    }
}
