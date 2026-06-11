//
//  NoticeTooltipMemory.swift
//  Mople
//
//  Created by CatSlave on 6/11/26.
//

import Foundation

// 모임 상세의 "공지를 작성해보세요" 작성 유도 툴팁 표시 이력 저장소.
// 모임별로 1회만 노출되도록 UserDefaults에 meetId별 seen 플래그 기록.
enum NoticeTooltipMemory {

    private static let keyPrefix = "com.mople.noticeTooltipSeen."

    static func hasSeen(meetId: Int?) -> Bool {
        guard let meetId else { return false }
        return UserDefaults.standard.bool(forKey: keyPrefix + String(meetId))
    }

    static func markSeen(meetId: Int?) {
        guard let meetId else { return }
        UserDefaults.standard.set(true, forKey: keyPrefix + String(meetId))
    }
}
