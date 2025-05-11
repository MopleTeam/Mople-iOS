//
//  FetchNotifyState.swift
//  Mople
//
//  Created by CatSlave on 4/11/25.
//

import RxSwift

protocol FetchNotifyState {
    func execute() -> Observable<[SubscribeType]>
}

final class FetchNotifyStateUseCase: FetchNotifyState {
    
    private let repo: NotifySubscribeRepo
    
    init(repo: NotifySubscribeRepo) {
        self.repo = repo
    }
    
    func execute() -> Observable<[SubscribeType]> {
        return repo.fetchNotifyState()
            .map { $0.compactMap { typeString in
                switch typeString {
                case "MEET":
                    return SubscribeType.meet
                case "PLAN":
                    return SubscribeType.plan
                default:
                    return nil
                }
            }}
            .asObservable()
    }
}
