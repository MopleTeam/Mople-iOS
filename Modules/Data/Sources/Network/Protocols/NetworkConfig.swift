//
//  NetworkConfig.swift
//  Data
//
//  네트워크 설정 프로토콜 (baseURL, headers 등)
//  구현체(ApiDataNetworkConfig)는 App 타겟에 위치
//

import Foundation

public protocol NetworkConfigurable {
    var baseURL: URL? { get }
    var headers: [String: String] { get }
    var queryParameters: [String: String] { get }
}
