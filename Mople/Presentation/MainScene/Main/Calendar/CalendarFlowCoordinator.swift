//
//  CalendarFlowCoordinator.swift
//  Mople
//
//  Created by CatSlave on 1/13/25.
//

import UIKit

protocol CalendarFlowCoordination {
    
}

final class CalendarFlowCoordinator: BaseCoordinator {
    
    let dependency: CalendarSceneDependencies
    
    init(navigationController: AppNaviViewController,
         dependency: CalendarSceneDependencies) {
        self.dependency = dependency
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        let calendarVC = dependency.makeCalendarScheduleViewcontroller()
        self.navigationController.pushViewController(calendarVC, animated: false)
    }
}
