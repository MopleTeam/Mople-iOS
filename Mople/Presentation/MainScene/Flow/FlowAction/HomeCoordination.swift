//
//  HomeViewAction.swift
//  Mople
//
//  Created by CatSlave on 1/4/25.
//

import Foundation

protocol HomeCoordination: MainCoordination {
    func pushCalendarView(lastRecentDate: Date)
}

extension MainSceneCoordinator: HomeCoordination {
    // MARK: - 캘린더 뷰 이동
    /// - Parameter lastRecentDate: 이동시 표시할 데이트
    func pushCalendarView(lastRecentDate: Date) {
        self.switchTap(route: .calendar(presentDate: lastRecentDate))
    }
}
