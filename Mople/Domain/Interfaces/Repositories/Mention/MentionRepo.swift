//
//  MentionRepo.swift
//  Mople
//
//  Created by CatSlave on 8/5/25.
//

import RxSwift

protocol MentionRepo {
    func execute(meetId: Int, cursor: String?, keyword: String?) -> Single<PageResponse<MemberInfoResponse>>
}
