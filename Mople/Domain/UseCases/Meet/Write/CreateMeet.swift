//
//  CreateGroup.swift
//  Group
//
//  Created by CatSlave on 11/19/24.
//

import UIKit
import RxSwift

protocol CreateMeet {
    func createMeet(title: String, imagePath: String?) -> Single<Meet>
}

final class CreateMeetUseCase: CreateMeet {
    
    let createMeetRepo: MeetCommandRepo
    
    init(createMeetRepo: MeetCommandRepo) {
        self.createMeetRepo = createMeetRepo
    }
    
    func createMeet(title: String,
                    imagePath: String?) -> Single<Meet> {
        return self.createMeetRepo
            .createMeet(.init(name: title,
                              image: imagePath))
            .map { $0.toDomain() }
    }
}


