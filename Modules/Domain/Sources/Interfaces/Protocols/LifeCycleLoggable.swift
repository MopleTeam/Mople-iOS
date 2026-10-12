//
//  LifeCycleLoggable.swift
//  Domain
//
//  객체 생성/해제 로깅 프로토콜 — 메모리 관리 추적용

import Foundation

/// init/deinit 시점에 로그를 출력하여 메모리 누수를 추적하는 프로토콜
public protocol LifeCycleLoggable {
    func logLifeCycle(function: String, line: Int)
}

public extension LifeCycleLoggable {
    func logLifeCycle(function: String = #function, line: Int = #line) {
        #if DEBUG
        let className = String(describing: type(of: self))
        print("[\(className)] \(function):\(line)")
        #endif
    }
}
