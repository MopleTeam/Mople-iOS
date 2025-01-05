//
//  FetchGroup.swift
//  Mople
//
//  Created by CatSlave on 1/5/25.
//

import RxSwift

protocol FetchGroupUseCase {
    func fetchGroup(groupId: Int) -> Single<Meet>
}
