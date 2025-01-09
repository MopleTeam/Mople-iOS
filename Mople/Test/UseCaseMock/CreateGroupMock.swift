//
//  CreateGroupMock.swift
//  Group
//
//  Created by CatSlave on 11/19/24.
//

import UIKit
import RxSwift

final class CreateGroupMock: CreateMeet {
    func createMeet(title: String, image: UIImage?) -> Single<Meet> {
        return Observable.just(.mock(id: 999, creatorId: 999))
            .delay(.seconds(2), scheduler: MainScheduler.instance)
            .asSingle()
    }
}
