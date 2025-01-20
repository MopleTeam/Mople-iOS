//
//  FetchMeetListRepo.swift
//  Mople
//
//  Created by CatSlave on 1/9/25.
//

import RxSwift

protocol MeetQueryRepo {
    func fetchMeetList() -> Single<[MeetResponse]>
    func fetchMeetDetail(meetId: Int) -> Single<MeetResponse>
}
