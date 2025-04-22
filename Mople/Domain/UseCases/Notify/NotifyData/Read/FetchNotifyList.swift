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
        let newCount = getNewCount()
        return repo.fetchNotifyList()
            .observe(on: MainScheduler.instance)
            .map { $0.map { $0.toDomain() } }
            .map { [weak self] in
                guard let self else { return [] }
                if newCount > 0 {
                    return updateReadStatus(list: $0, newCount: newCount)
                } else {
                    return $0
                }
            }
    }
    
    private func getNewCount() -> Int {
        let newCount = UserInfoStorage.shared.userInfo?.notifyCount ?? 0
        print(#function, #line, "newCount : \(newCount)" )
        return newCount
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
