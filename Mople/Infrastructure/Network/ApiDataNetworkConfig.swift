//
//  ApiDataNetworkConfig.swift
//  Mople
//
//  NetworkConfigurable 프로토콜의 App 측 구현체
//  (프로토콜 정의는 Data 모듈로 이전됨)
//

import Foundation
import Data

/// 앱에서 사용하는 기본 네트워크 설정 구조체
struct ApiDataNetworkConfig: NetworkConfigurable {
    let baseURL: URL?
    let headers: [String: String]
    let queryParameters: [String: String]

    init(
        baseURL: URL?,
        headers: [String: String] = [:],
        queryParameters: [String: String] = [:]
    ) {
        self.baseURL = baseURL
        self.headers = headers
        self.queryParameters = queryParameters
    }
}
