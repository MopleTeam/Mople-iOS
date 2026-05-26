//
//  PinnedNoticeResponse.swift
//  Data
//
//  Created by CatSlave on 5/26/26.
//

import Foundation
import Domain

// MeetDetail 응답에 nested로 포함되는 고정 공지 DTO
struct PinnedNoticeResponse: Decodable {
    let noticeId: Int?
    let version: Int?
    let meetId: Int?
    let type: String?
    let content: String?
    let pinned: Bool?
    let createdAt: String?
}

extension PinnedNoticeResponse {
    func toDomain() -> PinnedNotice {
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
