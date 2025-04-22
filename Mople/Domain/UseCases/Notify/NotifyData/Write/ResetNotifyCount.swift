//
//  ResetNotifyCount.swift
//  Mople
//
//  Created by CatSlave on 4/22/25.
//

import RxSwift

protocol ResetNotifyCount {
    func execute() -> Single<Void>
}

final class ResetNotifyCountUseCase: ResetNotifyCount {
    private let repo: NotifyRepo
    
    init(repo: NotifyRepo) {
        self.repo = repo
    }
    
    func execute() -> Single<Void> {
        repo.resetNotifyCount()
    }
}
