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
