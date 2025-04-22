//
//  FetchGroupList.swift
//  Group
//
//  Created by CatSlave on 9/10/24.
//

import Foundation
import RxSwift

protocol FetchMeetList {
    func execute() -> Single<[Meet]>
}

final class FetchMeetListUseCase: FetchMeetList {
  
    private let repo: MeetRepo
    
    init(repo: MeetRepo) {
        self.repo = repo
    }
    
    func execute() -> Single<[Meet]> {
        return repo.fetchMeetList()
            .map { $0.map { response in
                response.toDomain() }
            }
    }
}
