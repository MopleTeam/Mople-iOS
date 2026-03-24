//
//  ResetNotifyCount.swift
//  Mople
//
//  Created by CatSlave on 4/22/25.
//

import RxSwift

protocol ResetNotifyCount {
    func execute() -> Observable<Void>
}

final class ResetNotifyCountUseCase: ResetNotifyCount {
    private let repo: NotifyRepo
    
    init(repo: NotifyRepo) {
        self.repo = repo
    }
    
    func execute() -> Observable<Void> {
        repo.resetNotifyCount()
            .asObservable()
    }
}

// MARK: - Mock
#if DEV
final class MockResetNotifyCountUseCase: ResetNotifyCount {
    func execute() -> Observable<Void> {
        print("✅ [Mock] 알림 카운트 초기화")
        return Observable.just(())
            .delay(.seconds(1), scheduler: MainScheduler.instance)
    }
}
#endif
