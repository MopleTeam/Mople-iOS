//
//  NoticeType.swift
//  Domain
//
//  Created by CatSlave on 5/26/26.
//

import Foundation

// 모임 공지 분류 — 모임장이 작성한 사용자 공지(custom)와 시스템이 자동 발행한 공지(system) 두 가지
public enum NoticeType: String, Sendable {
    case custom = "CUSTOM"
    case system = "SYSTEM"
}
