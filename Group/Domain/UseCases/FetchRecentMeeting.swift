//
//  FetchRecentMeeting.swift
//  Group
//
//  Created by CatSlave on 8/31/24.

import Foundation
import RxSwift

protocol FetchRecentSchedule {
    func fetchRecent() -> Single<[Schedule]>
}


    





