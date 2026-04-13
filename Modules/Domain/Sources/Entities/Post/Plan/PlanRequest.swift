//
//  PlanRequest.swift
//  Domain
//
//  일정 생성/수정 요청 모델

import Foundation

/// 일정 요청 타입 — 생성(meetId) 또는 수정(planId) 구분
public enum PlanRequestType {
    case create(meetId: Int)
    case edit(planId: Int)
}

/// 일정 생성/수정 요청 데이터
/// Data 레이어에서 API용 DTO로 변환한다
public struct PlanRequest {
    public let type: PlanRequestType
    public let name: String
    public let date: String
    public var description: String?
    public var place: PlaceInfo?

    public init(type: PlanRequestType,
                name: String,
                date: String,
                description: String? = nil,
                place: PlaceInfo? = nil) {
        self.type = type
        self.name = name
        self.date = date
        self.description = description
        self.place = place
    }
}
