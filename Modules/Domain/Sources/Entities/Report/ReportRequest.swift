//
//  ReportRequest.swift
//  Domain
//
//  신고 요청 모델

import Foundation

/// 신고 대상 유형
public enum ReportType {
    case plan(id: Int)
    case review(id: Int)
    case comment(id: Int)
}

/// 신고 요청 데이터
public struct ReportRequest {
    public let type: ReportType
    public let reason: String?

    public init(type: ReportType, reason: String?) {
        self.type = type
        self.reason = reason
    }
}
