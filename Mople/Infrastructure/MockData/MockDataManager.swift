//
//  MockDataManager.swift
//  Mople
//
//  Created by CatSlave on 3/18/26.
//

#if DEV
import Foundation
import RxSwift
import RxRelay

// Dev 환경에서 목업/서버 데이터 전환을 관리하는 싱글톤
final class MockDataManager {

    static let shared = MockDataManager()

    private let userDefaultsKey = "com.mople.dev.useMockData"

    // 현재 목업 모드 상태를 방출하는 Relay
    private let isMockModeRelay: BehaviorRelay<Bool>

    // 외부에서 구독할 수 있는 Observable
    var isMockMode: Observable<Bool> {
        return isMockModeRelay.asObservable()
    }

    // 현재 목업 모드 여부 (동기적 접근)
    var useMockData: Bool {
        return isMockModeRelay.value
    }

    private init() {
        let savedValue = UserDefaults.standard.bool(forKey: userDefaultsKey)
        self.isMockModeRelay = BehaviorRelay(value: savedValue)
    }

    // 목업 모드 토글
    func toggle() {
        let newValue = !isMockModeRelay.value
        isMockModeRelay.accept(newValue)
        UserDefaults.standard.set(newValue, forKey: userDefaultsKey)
    }

    // Mock/Real UseCase 분기 처리
    static func resolve<T>(_ real: T, mock: T) -> T {
        return MockDataManager.shared.useMockData ? mock : real
    }
}
#endif
