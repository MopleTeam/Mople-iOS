//
//  SubscribeNotify.swift
//  Mople
//
//  Created by CatSlave on 4/11/25.
//

import RxSwift

protocol SubscribeNotify {
    func execute(type: SubscribeType, isSubscribe: Bool) -> Observable<Void>
}

final class SubscribeNotifyUseCase: SubscribeNotify {
    
    private let repo: NotifySubscribeRepo
    
    init(repo: NotifySubscribeRepo) {
        self.repo = repo
    }
    
    func execute(type: SubscribeType, isSubscribe: Bool) -> Observable<Void> {
        return repo
            .subscribeNotify(type: type,
                             isSubscribe: isSubscribe)
            .asObservable()
    }
}

// MARK: - Mock
#if DEV
final class MockSubscribeNotifyUseCase: SubscribeNotify {
    func execute(type: SubscribeType, isSubscribe: Bool) -> Observable<Void> {
        print("✅ [Mock] 알림 구독 변경 - type: \(type.rawValue), isSubscribe: \(isSubscribe)")
        return Observable.just(())
            .delay(.seconds(1), scheduler: MainScheduler.instance)
    }
}
#endif
