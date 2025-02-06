//
//  MemberInfoRepo.swift
//  Mople
//
//  Created by CatSlave on 2/4/25.
//

import RxSwift

protocol MemberListRepo {
    func execute(type: MemberListType) -> Single<MemberListResponse>
}
