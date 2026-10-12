//
//  SearchLocationRequest.swift
//  Domain
//
//  장소 검색 요청 모델

import Foundation

/// 장소 검색 요청 데이터
public struct SearchLocationRequest {
    public let query: String
    public let x: Double?
    public let y: Double?

    public init(query: String, x: Double? = nil, y: Double? = nil) {
        self.query = query
        self.x = x
        self.y = y
    }
}
