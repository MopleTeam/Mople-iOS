//
//  SubscribeNotify.swift
//  Mople
//
//  Created by CatSlave on 4/11/25.
//

import RxSwift

protocol SubscribeNotify {
    func execute(type: SubscribeType, isSubscribe: Bool) -> Single<Void>
}

final class SubscribeNotifyUseCase: SubscribeNotify {
    
    private let repo: NotifySubscribeRepo
    
    init(repo: NotifySubscribeRepo) {
        self.repo = repo
    }
    
    func execute(type: SubscribeType, isSubscribe: Bool) -> Single<Void> {
        return repo.subscribeNotify(type: type,
                                    isSubscribe: isSubscribe)
    }
}
