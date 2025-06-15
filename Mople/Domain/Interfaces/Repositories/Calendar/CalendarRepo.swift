//
//  CalendarRepo.swift
//  Mople
//
//  Created by CatSlave on 2/24/25.
//

import RxSwift

protocol CalendarRepo {
    func fetchAllDates() -> Single<AllPlanDateResponse>
    func fetchHolidays(for year: Int) -> Single<[HolidayResponse]>
    func fetchMonthlyPost(month: String) -> Single<MonthlyPostResponse>
}

