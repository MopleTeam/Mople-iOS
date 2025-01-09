//
//  FetchMeetDetailRepo.swift
//  Mople
//
//  Created by CatSlave on 1/9/25.
//

import RxSwift

protocol MeetDetailRepo {
    func fetchMeetDetail(meetId: Int) -> Single<MeetResponse>
}
