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
            .flatMap { [weak self] page -> Observable<Page<Notify>> in
                guard let self else { return .empty() }
                var newPage = page
                updateReadStatus(page: &newPage)
                return .just(newPage)
            }
    }
    
    private func updateReadStatus(page: inout Page<Notify>) {
        guard page.totalCount > 0 else { return }
        let newIndex = page.totalCount - 1
        
        (0...newIndex).forEach {
            page.content[$0].isNew = true
        }
    }
}
