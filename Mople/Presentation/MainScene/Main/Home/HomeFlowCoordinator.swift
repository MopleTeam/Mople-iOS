//
//  HomeFlowCoordinator.swift
//  Mople
//
//  Created by CatSlave on 1/13/25.
//

import UIKit

protocol HomeFlowCoordination: AnyObject {
    func presentMeetCreateView()
    func presentPlanCreateView(meetList: [MeetSummary])
    func presentPlanDetailView(planId: Int)
    func pushCalendarView(lastRecentDate: Date)
}

final class HomeFlowCoordinator: BaseCoordinator, HomeFlowCoordination {
    
    private let dependencies: HomeSceneDependencies
    
    init(navigationController: AppNaviViewController, dependencies: HomeSceneDependencies) {
        self.dependencies = dependencies
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        let homeVC = dependencies.makeHomeViewController(coordinator: self)
        self.navigationController.pushViewController(homeVC, animated: false)
    }
}

// MARK: - 뷰 이동
extension HomeFlowCoordinator: MeetCreateViewCoordination  {
    func presentMeetCreateView() {
        let meetCreateVC = dependencies.makeMeetCreateViewController(coordinator: self)
        self.navigationController.presentWithTransition(meetCreateVC)
    }
}

// MARK: - Flow 이동
extension HomeFlowCoordinator {
    func presentPlanCreateView(meetList: [MeetSummary]) {
        let planCreateFlowCoordiator = dependencies.makePlanCreateFlowCoordinator(meetList: meetList)
        self.start(coordinator: planCreateFlowCoordiator)
        self.navigationController.presentWithTransition(planCreateFlowCoordiator.navigationController)
    }
    
    func presentPlanDetailView(planId: Int) {
        let planDetailCoordinates = dependencies.makePlanDetailFlowCoordinator(postId: planId)
        self.start(coordinator: planDetailCoordinates)
        self.navigationController.presentWithTransition(planDetailCoordinates.navigationController)
    }
}

// MARK: - 탭바 이동
extension HomeFlowCoordinator {
    func pushCalendarView(lastRecentDate: Date) {
        guard let mainCoordination = self.parentCoordinator as? MainCoordination else { return }
        mainCoordination.changeCalendarTap(date: lastRecentDate)
    }
}

