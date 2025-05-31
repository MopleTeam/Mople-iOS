//
//  CalendarRepo.swift
//  Mople
//
//  Created by CatSlave on 2/24/25.
//

import RxSwift

protocol CalendarRepo {
    func fetchAllDates() -> Single<AllPlanDateResponse>
    func fetchMonthlyPost(month: String) -> Single<MonthlyPostResponse>
}

