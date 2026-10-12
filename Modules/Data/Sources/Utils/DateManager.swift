//
//  DateManager.swift
//  Data
//
//  서버 응답 DTO 파싱용 날짜 유틸리티
//  App 측 DateManager(Infrastructure)와 동일한 서버 포맷을 Data 내부 네임스페이스에서 제공
//  - App의 DateManager(클래스)와 이름이 같지만 타입 네임스페이스가 달라 충돌 없음
//  - App 코드가 `import Data` 한 파일에서 `DateManager`라고 쓰면 App 자체 타입이 우선됨
//

import Foundation

/// Data 모듈 내부 전용 서버 날짜 파서
public enum DateManager {

    /// 서버 풀 날짜 포맷: yyyy-MM-dd HH:mm:ss
    public static let fullServerDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()

    /// 서버 심플 날짜 포맷: yyyy-MM-dd
    public static let simpleServerDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    /// 서버 풀 문자열 → Date
    public static func parseServerFullDate(string: String?) -> Date? {
        guard let string else { return nil }
        return fullServerDateFormatter.date(from: string)
    }

    /// 서버 심플 문자열 → Date
    public static func parseServerSimpleDate(string: String?) -> Date? {
        guard let string else { return nil }
        return simpleServerDateFormatter.date(from: string)
    }
}
