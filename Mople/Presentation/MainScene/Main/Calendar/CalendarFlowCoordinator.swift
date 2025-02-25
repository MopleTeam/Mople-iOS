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
        let calendarVC = makeMainViewController()
        self.navigationController.pushViewController(calendarVC, animated: false)
    }
}

extension CalendarFlowCoordinator {
    private func makeMainViewController() -> CalendarScheduleViewController {
        let mainVC = dependency.makeCalendarScheduleViewcontroller()
        let calendarContainer = mainVC.calendarContainer
        let scheduleListContainer = mainVC.scheduleListContainer
        addCalendarView(parentVC: mainVC, container: calendarContainer)
        addScheduleListView(parentVC: mainVC, container: scheduleListContainer)
        return mainVC
    }
    
    private func addCalendarView(parentVC: CalendarScheduleViewController, container: UIView) {
        let calendarVC = dependency.makeCalendarViewController()
        parentVC.add(child: calendarVC, container: container)
    }
    
    private func addScheduleListView(parentVC: CalendarScheduleViewController, container: UIView) {
        let calendarVC = dependency.makeScheduleListViewController()
        parentVC.add(child: calendarVC, container: container)
    }
}
