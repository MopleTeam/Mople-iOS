//
//  FetchNotifyList.swift
//  Mople
//
//  Created by CatSlave on 4/10/25.
//

import RxSwift

protocol FetchNotifyList {
    func execute() -> Single<[Notify]>
}

final class FetchNotifyListUseCase: FetchNotifyList {
    
    private let repo: NotifyRepo
    
    init(repo: NotifyRepo) {
        self.repo = repo
    }
    
    func execute() -> Single<[Notify]> {
        return repo.fetchNotifyList()
            .map { $0.map { $0.toDomain() } }
    }
}
