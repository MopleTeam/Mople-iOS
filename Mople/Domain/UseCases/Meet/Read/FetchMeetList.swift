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
  
    let meetListRepo: MeetQueryRepo
    
    init(meetListRepo: MeetQueryRepo) {
        self.meetListRepo = meetListRepo
    }
    
    func execute() -> Single<[Meet]> {
        return meetListRepo.fetchMeetList()
            .map { $0.map { response in
                response.toDomain() }
            }
    }
}
