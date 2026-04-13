//
//  ServerErrorIdentifiable.swift
//  Mople
//
//  Created by CatSlave on 4/10/26.
//

import Foundation

/// 서버 에러 식별 프로토콜 — Domain에서 정의, Infrastructure에서 구현
/// DataRequestError 등 네트워크 에러가 이 프로토콜을 채택하여
/// Domain이 Infrastructure 타입을 직접 참조하지 않고 에러를 분류할 수 있게 한다
protocol ServerErrorIdentifiable: Error {
    /// 서버에 해당 리소스(계정 등)가 없음 (404/noResponse)
    var isNotFound: Bool { get }
}
