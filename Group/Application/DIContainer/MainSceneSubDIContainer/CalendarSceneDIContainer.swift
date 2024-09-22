//
//  CalendarSceneDIContainer.swift
//  Group
//
//  Created by CatSlave on 8/31/24.
//

import UIKit

final class CalendarSceneDIContainer: CalendarCoordinatorDependencies {
   
    let apiDataTransferService: DataTransferService

    init(apiDataTransferService: DataTransferService) {
        self.apiDataTransferService = apiDataTransferService
    }
    
    func makeCalendarFlowCoordinator(navigationController: UINavigationController) -> CalendarCoordinator {
        let flow = CalendarCoordinator(navigationController: navigationController,
                                        dependencies: self)
        return flow
    }
    
    func makeCalendarViewController() -> CalendarAndEventsViewController {
        return CalendarAndEventsViewController(title: "일정관리",
                                               reactor: makeCalendarViewReactor())
    }

    private func makeCalendarViewReactor() -> CalendarViewReactor {
        return CalendarViewReactor(fetchUseCase: fetchRecentScheduleMock())
    }
    
}
