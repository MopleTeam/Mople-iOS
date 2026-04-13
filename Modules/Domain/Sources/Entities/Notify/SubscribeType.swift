//
//  SubscribeType.swift
//  Domain
//
//  알림 구독 유형

import Foundation

/// 알림 구독 유형 — 서버 API의 String 값과 매핑
public enum SubscribeType: String {
    case meet = "MEET"
    case plan = "PLAN"
    case mention = "MENTION"
    case reply = "REPLY"
}
