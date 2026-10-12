//
//  CreateMeetRequest.swift
//  Domain
//
//  모임 생성/수정 요청 모델

import Foundation

/// 모임 생성 및 수정 시 필요한 데이터
public struct CreateMeetRequest {
    public var name: String?
    public var image: String?

    public init(name: String? = nil, image: String? = nil) {
        self.name = name
        self.image = image
    }
}
