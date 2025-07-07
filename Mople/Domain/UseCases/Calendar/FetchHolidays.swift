//
//  FetchHolidays.swift
//  Mople
//
//  Created by CatSlave on 6/15/25.
//

import RxSwift

protocol FetchHolidays {
    func execute(for year: Int) -> Observable<[Holiday]>
}

final class FetchHolidaysUseCase: FetchHolidays {
    
    private let repo: CalendarRepo
    
    init(repo: CalendarRepo) {
        self.repo = repo
    }
    
    func execute(for year: Int) -> Observable<[Holiday]> {
        return repo.fetchHolidays(for: year)
            .map { $0.map { $0.toDomain() } }
            .asObservable()
    }
}
