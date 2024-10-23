//
//  CalendarSceneDIContainer.swift
//  Group
//
//  Created by CatSlave on 8/31/24.
//

import UIKit

final class CalendarSceneDIContainer: CalendarCoordinatorDependencies {
   
    let appNetworkService: AppNetWorkService

    init(appNetworkService: AppNetWorkService) {
        self.appNetworkService = appNetworkService
    }
    
    func makeCalendarFlowCoordinator(navigationController: UINavigationController) -> CalendarCoordinator {
        let flow = CalendarCoordinator(navigationController: navigationController,
                                        dependencies: self)
        return flow
    }
    
    func makeCalendarViewController() -> CalendarScheduleViewController {
        return CalendarScheduleViewController(title: "일정관리",
                                               reactor: makeCalendarViewReactor())
    }

    private func makeCalendarViewReactor() -> CalendarViewReactor {
        return CalendarViewReactor(fetchUseCase: FetchScheduleMock())
    }
    
}
