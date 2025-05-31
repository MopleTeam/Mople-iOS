//
//  CreateGroup.swift
//  Group
//
//  Created by CatSlave on 11/19/24.
//

import Foundation
import RxSwift

protocol CreateMeet {
    func execute(requset: CreateMeetRequest) -> Observable<Meet>
}

final class CreateMeetUseCase: CreateMeet {
    
    let createMeetRepo: MeetRepo
    
    init(createMeetRepo: MeetRepo) {
        self.createMeetRepo = createMeetRepo
    }
    
    func execute(requset: CreateMeetRequest) -> Observable<Meet> {
        return self.createMeetRepo
            .createMeet(reqeust: requset)
            .map { $0.toDomain() }
            .asObservable()
    }
}


