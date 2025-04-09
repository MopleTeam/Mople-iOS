//
//  CreateGroup.swift
//  Group
//
//  Created by CatSlave on 11/19/24.
//

import Foundation
import RxSwift

protocol CreateMeet {
    func execute(requset: CreateMeetRequest) -> Single<Meet?>
}

final class CreateMeetUseCase: CreateMeet {
    
    let createMeetRepo: MeetCommandRepo
    
    init(createMeetRepo: MeetCommandRepo) {
        self.createMeetRepo = createMeetRepo
    }
    
    func execute(requset: CreateMeetRequest) -> Single<Meet?> {
        return self.createMeetRepo
            .createMeet(reqeust: requset)
            .map { $0.toDomain() }
    }
}


