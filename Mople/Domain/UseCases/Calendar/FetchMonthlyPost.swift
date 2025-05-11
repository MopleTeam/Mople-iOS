//
//  FetchCalendarPaingDate.swift
//  Mople
//
//  Created by CatSlave on 2/24/25.
//

import Foundation
import RxSwift

protocol FetchMonthlyPost {
    func execute(month: String) -> Observable<[MonthlyPost]>
}

final class FetchMonthlyPostUseCase: FetchMonthlyPost {
    
    private let repo: CalendarRepo
    
    init(repo: CalendarRepo) {
        self.repo = repo
    }
    
    func execute(month: String) -> Observable<[MonthlyPost]> {
        return repo.fetchMonthlyPost(month: month)
            .map { $0.toDomain() }
            .asObservable()
    }
}
