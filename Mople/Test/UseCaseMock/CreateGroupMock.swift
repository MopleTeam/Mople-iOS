//
//  CreateGroupMock.swift
//  Group
//
//  Created by CatSlave on 11/19/24.
//

import UIKit
import RxSwift

final class CreateGroupMock: CreateMeet {
    func execute(title: String, imagePath: String?) -> Single<Meet> {
        return Observable.just(.mock(id: 999, creatorId: 999))
            .delay(.seconds(2), scheduler: MainScheduler.instance)
            .asSingle()
    }
}
