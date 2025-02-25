//
//  FetchCalendarPaingDate.swift
//  Mople
//
//  Created by CatSlave on 2/24/25.
//

import Foundation
import RxSwift

protocol FetchMonthlyPlan {
    func execute(month: String) -> Single<[MonthlyPlan]>
}

final class FetchMonthlyPlanUseCase: FetchMonthlyPlan {
    
    private let repo: CalendarRepo
    
    init(repo: CalendarRepo) {
        self.repo = repo
    }
    
    func execute(month: String) -> Single<[MonthlyPlan]> {
        return repo.fetchMonthlyPlan(month: month)
            .map { $0.toDomain() }
    }
}
