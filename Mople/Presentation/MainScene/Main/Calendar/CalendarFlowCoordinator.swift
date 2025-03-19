//
//  CalendarFlowCoordinator.swift
//  Mople
//
//  Created by CatSlave on 1/13/25.
//

import UIKit

protocol CalendarCoordination: AnyObject {
    func pushPlanDetailView(postId: Int,
                            type: PlanDetailType)
}

final class CalendarFlowCoordinator: BaseCoordinator, CalendarCoordination {
    
    private let dependencies: CalendarSceneDependencies
    
    init(navigationController: AppNaviViewController,
         dependency: CalendarSceneDependencies) {
        self.dependencies = dependency
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        let calendarVC = makeMainViewController()
        self.navigationController.pushViewController(calendarVC, animated: false)
    }
}

// MARK: - 기본 뷰
extension CalendarFlowCoordinator {
    private func makeMainViewController() -> CalendarScheduleViewController {
        let mainVC = dependencies.makeCalendarScheduleViewcontroller(coordinator: self)
        let calendarContainer = mainVC.calendarContainer
        let scheduleListContainer = mainVC.scheduleListContainer
        addCalendarView(parentVC: mainVC, container: calendarContainer)
        addScheduleListView(parentVC: mainVC, container: scheduleListContainer)
        return mainVC
    }
    
    private func addCalendarView(parentVC: CalendarScheduleViewController, container: UIView) {
        let calendarVC = dependencies.makeCalendarViewController()
        parentVC.add(child: calendarVC, container: container)
    }
    
    private func addScheduleListView(parentVC: CalendarScheduleViewController, container: UIView) {
        let calendarVC = dependencies.makeScheduleListViewController()
        parentVC.add(child: calendarVC, container: container)
    }
}

// MARK: - Flow
extension CalendarFlowCoordinator {
    func pushPlanDetailView(postId: Int,
                            type: PlanDetailType) {
        let planDetailFlowCoordinator = dependencies.makePlanDetailFlowCoordinator(postId: postId,
                                                                                   type: type)
        start(coordinator: planDetailFlowCoordinator)
        navigationController.presentWithTransition(planDetailFlowCoordinator.navigationController)
    }
}
