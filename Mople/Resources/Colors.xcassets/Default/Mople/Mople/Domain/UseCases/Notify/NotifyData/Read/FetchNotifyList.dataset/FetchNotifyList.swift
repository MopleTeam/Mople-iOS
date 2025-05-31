//
//  FetchNotifyList.swift
//  Mople
//
//  Created by CatSlave on 4/10/25.
//

import RxSwift

protocol FetchNotifyList {
    func execute() -> Observable<[Notify]>
}

final class FetchNotifyListUseCase: FetchNotifyList {
    
    private let repo: NotifyRepo
    
    init(repo: NotifyRepo) {
        self.repo = repo
    }
    
    func execute() -> Observable<[Notify]> {
        let newCount = getNewCount()
        return repo.fetchNotifyList()
            .asObservable()
            .map { $0.map { $0.toDomain() } }
            .flatMap { [weak self] notifyList -> Observable<[Notify]> in
                guard let self else { return .empty() }
                if newCount > 0 {
                    let adjustReadState = updateReadStatus(list: notifyList,
                                                           newCount: newCount)
                    return .just(adjustReadState)
                } else {
                    return .just(notifyList)
                }
            }
    }
    
    private func getNewCount() -> Int {
        return UserInfoStorage.shared.userInfo?.notifyCount ?? 0
    }
    
    private func updateReadStatus(list: [Notify], newCount: Int) -> [Notify] {
        var updateList = list
        let newIndex = newCount - 1
        (0...newIndex).forEach {
            guard let _ = updateList[safe: $0] else { return }
            updateList[$0].isNew = true
        }
        return updateList
    }
}
