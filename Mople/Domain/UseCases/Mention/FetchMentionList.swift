//
//  FetchMentionList.swift
//  Mople
//
//  Created by CatSlave on 8/5/25.
//

import RxSwift

protocol FetchMentionList {
    func execute(cursor: String?, keyword: String?) -> Observable<MemberPage>
}

final class FetchMentionListUseCase: FetchMentionList {
    
    private let postId: Int
    private let repo: MentionRepo
    
    init(postId: Int,
         repo: MentionRepo) {
        self.postId = postId
        self.repo = repo
    }
    func execute(cursor: String?,
                 keyword: String?) -> Observable<MemberPage> {
        
        return repo.execute(postId: postId,
                            cursor: cursor,
                            keyword: keyword)
        .asObservable()
        .map { $0.toDomain() }
        
    }
}
