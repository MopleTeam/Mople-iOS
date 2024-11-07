//
//  FetchScheduleList.swift
//  Group
//
//  Created by CatSlave on 10/7/24.
//

import Foundation
import RxSwift

protocol FetchSchedule {
    func fetchScheduleList() -> Single<[SimpleSchedule]>
}
