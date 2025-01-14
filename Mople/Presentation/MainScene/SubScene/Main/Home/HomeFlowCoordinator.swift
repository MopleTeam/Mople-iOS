//
//  HomeFlowCoordinator.swift
//  Mople
//
//  Created by CatSlave on 1/13/25.
//

import UIKit

protocol HomeFlowCoordination {
    func presentMeetCreateView()
    func presentPlanCreateView(meetList: [MeetSummary])
    func presentPlanDetailView(plan: Plan)
    func pushCalendarView(lastRecentDate: Date)
}

final class HomeFlowCoordinator: BaseCoordinator {
    
    private let dependencies: HomeSceneDependencies
    
    init(navigationController: AppNaviViewController, dependencies: HomeSceneDependencies) {
        self.dependencies = dependencies
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        let homeVC = dependencies.makeHomeViewController(coordinator: self)
        self.navigationController.pushViewController(homeVC, animated: false)
    }
    
    func dismiss() {
        self.navigationController.dismiss(animated: true)
    }
}

extension HomeFlowCoordinator: HomeFlowCoordination {
    func presentMeetCreateView() {
        let meetCreateVC = dependencies.makeMeetCreateViewController(navigator: self)
        self.navigationController.presentWithTransition(meetCreateVC)
    }
    
    func presentPlanCreateView(meetList: [MeetSummary]) {
        let planCreateFlowCoordiator = dependencies.makePlanCreateFlowCoordinator(meetList: meetList)
        self.start(coordinator: planCreateFlowCoordiator)
        self.navigationController.presentWithTransition(planCreateFlowCoordiator.navigationController)
    }
    
    func presentPlanDetailView(plan: Plan) {
        let planDetailCoordinates = dependencies.makePlanDetailFlowCoordinator(plan: plan)
        self.start(coordinator: planDetailCoordinates)
        self.navigationController.presentWithTransition(planDetailCoordinates.navigationController)
    }
    
    func pushCalendarView(lastRecentDate: Date) {
        guard let mainCoordination = self.parentCoordinator as? MainCoordination else { return }
        mainCoordination.changeCalendarTap(date: lastRecentDate)
    }
}
