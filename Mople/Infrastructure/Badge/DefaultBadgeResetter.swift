//
//  DefaultBadgeResetter.swift
//  Mople
//
//  UIKit의 UIApplication 뱃지 초기화를 캡슐화
//  Data 모듈에서 UIKit 의존을 제거하기 위한 구현체
//

import UIKit
import Data

/// AppBadgeResettable 프로토콜의 구현체 (Data 모듈에 정의된 프로토콜)
final class DefaultBadgeResetter: AppBadgeResettable {
    @MainActor
    func resetBadge() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
}
