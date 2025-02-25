//
//  FetchCalendarDates.swift
//  Mople
//
//  Created by CatSlave on 2/24/25.
//

import Foundation
import RxSwift

protocol FetchAllPlanDate {
    func execute() -> Single<[Date]>
}

final class FetchAllPlanDateUseCase: FetchAllPlanDate {
    
    private let repo: CalendarRepo
    
    init(repo: CalendarRepo) {
        self.repo = repo
    }
    
    func execute() -> Single<[Date]> {
        return repo.fetchAllDates()
            .map { $0.toDomain() }
            .map { $0.dates }
    }
}
