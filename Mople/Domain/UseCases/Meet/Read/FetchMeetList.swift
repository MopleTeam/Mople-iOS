//
//  FetchGroupList.swift
//  Group
//
//  Created by CatSlave on 9/10/24.
//

import Foundation
import RxSwift

protocol FetchMeetPage {
    func execute(cursor: String?) -> Observable<Page<Meet>>
}

final class FetchMeetPageUseCase: FetchMeetPage {
  
    private let repo: MeetRepo
    
    init(repo: MeetRepo) {
        self.repo = repo
    }
    
    func execute(cursor: String?) -> Observable<Page<Meet>> {
        return repo.fetchMeetPage(cursor: cursor)
            .map { .init(totalCount: $0.totalCount ?? 0,
                         content: $0.content.map({ $0.toDomain() }),
                         info: $0.page?.toDomain()) }
            .asObservable()
    }
}
