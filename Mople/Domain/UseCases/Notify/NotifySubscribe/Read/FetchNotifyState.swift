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
                    return .meet
                case "PLAN":
                    return .plan
                case "REPLY":
                    return .reply
                case "MENTION":
                    return .mention
                default:
                    return nil
                }
            }}
            .asObservable()
    }
}
