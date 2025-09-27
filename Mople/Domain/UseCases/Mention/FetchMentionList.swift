//
//  FetchMentionList.swift
//  Mople
//
//  Created by CatSlave on 8/5/25.
//

import RxSwift

protocol FetchMentionList {
    func execute(meetId: Int, cursor: String?, keyword: String?) -> Observable<Page<MemberInfo>>
}

final class FetchMentionListUseCase: FetchMentionList {
    
    private let repo: MentionRepo
    
    init(repo: MentionRepo) {
        self.repo = repo
    }
    func execute(meetId: Int,
                 cursor: String?,
                 keyword: String?) -> Observable<Page<MemberInfo>> {
        
        return repo.execute(meetId: meetId,
                            cursor: cursor,
                            keyword: keyword)
        .asObservable()
        .map { Page(totalCount: $0.totalCount ?? 0,
                    content: $0.content.map({ $0.toDomain() }),
                    info: $0.page?.toDomain()) }
        
    }
}
