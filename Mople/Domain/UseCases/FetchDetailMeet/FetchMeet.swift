//
//  FetchGroup.swift
//  Mople
//
//  Created by CatSlave on 1/5/25.
//

import RxSwift

protocol FetchMeetUseCase {
    func fetchMeet(meetId: Int) -> Single<Meet>
}
