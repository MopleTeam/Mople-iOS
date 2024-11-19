//
//  CreateGroupMock.swift
//  Group
//
//  Created by CatSlave on 11/19/24.
//

import Foundation
import RxSwift

final class CreateGroupMock: CreateGroup {
    func createGroup(title: String, image: Data?) -> Single<Void> {
        return Observable.just(())
            .delay(.seconds(2), scheduler: MainScheduler.instance)
            .asSingle()
    }
}
