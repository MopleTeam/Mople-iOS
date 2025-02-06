//
//  FetchPlanMemberListMock.swift
//  Mople
//
//  Created by CatSlave on 2/4/25.
//

import RxSwift

final class FetchPlanMemberMock: FetchMemberList {
    func execute(type: MemberListType) -> Single<MemberList> {
        return Observable.just(MemberList.mock())
            .delay(.seconds(2), scheduler: MainScheduler.instance)
            .asSingle()
    }
}
