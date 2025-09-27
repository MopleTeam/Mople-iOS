//
//  FetchNotifyList.swift
//  Mople
//
//  Created by CatSlave on 4/10/25.
//

import RxSwift

protocol FetchNotifyList {
    func execute(cursor: String?) -> Observable<Page<Notify>>
}

final class FetchNotifyListUseCase: FetchNotifyList {
    
    private let repo: NotifyRepo
    
    init(repo: NotifyRepo) {
        self.repo = repo
    }
    
    func execute(cursor: String?) -> Observable<Page<Notify>> {
        return repo.fetchNotifyList(cursor: cursor)
            .asObservable()
            .map { Page(totalCount: $0.totalCount ?? 0,
                        content: $0.content.map({ $0.toDomain() }),
                        info: $0.page?.toDomain()) }
    }
}
