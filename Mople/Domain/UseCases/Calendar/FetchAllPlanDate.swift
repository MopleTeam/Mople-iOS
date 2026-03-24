//
//  FetchCalendarDates.swift
//  Mople
//
//  Created by CatSlave on 2/24/25.
//

import Foundation
import RxSwift

protocol FetchAllPlanDate {
    func execute() -> Observable<[Date]>
}

final class FetchAllPlanDateUseCase: FetchAllPlanDate {
    
    private let repo: CalendarRepo
    
    init(repo: CalendarRepo) {
        self.repo = repo
    }
    
    func execute() -> Observable<[Date]> {
        return repo.fetchAllDates()
            .map { $0.toDomain() }
            .map { $0.dates }
            .asObservable()
    }
}

// MARK: - Mock
#if DEV
final class MockFetchAllPlanDateUseCase: FetchAllPlanDate {
    func execute() -> Observable<[Date]> {
        print("✅ [Mock] 전체 일정 날짜 목록 조회")

        let calendar = Calendar.current
        let today = Date()
        let mockDates: [Date] = [
            today,
            calendar.date(byAdding: .day, value: 1, to: today)!,
            calendar.date(byAdding: .day, value: 3, to: today)!,
            calendar.date(byAdding: .day, value: 7, to: today)!,
            calendar.date(byAdding: .day, value: 14, to: today)!
        ]

        return Observable.just(mockDates)
            .delay(.seconds(1), scheduler: MainScheduler.instance)
    }
}
#endif
