//
//  HomeFlowCoordinator.swift
//  Mople
//
//  Created by CatSlave on 1/13/25.
//

import UIKit

protocol HomeFlowCoordination: AnyObject {
    func presentPlanCreateView(meetList: [MeetSummary])
    func presentMeetCreateView()
    func presentPlanDetailView(planId: Int, type: PlanDetailType)
    func pushCalendarView(lastRecentDate: Date)
    func presentNotifyView()
}

final class HomeFlowCoordinator: BaseCoordinator, HomeFlowCoordination {
    
    private let dependencies: HomeSceneDependencies
    
    init(navigationController: AppNaviViewController,
         dependencies: HomeSceneDependencies) {
        self.dependencies = dependencies
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        let homeVC = dependencies.makeHomeViewController(coordinator: self)
        self.navigationController.pushViewController(homeVC, animated: false)
    }
}

// MARK: - Create Meet View
extension HomeFlowCoordinator: MeetCreateViewCoordination  {
    func presentMeetCreateView() {
        let meetCreateVC = dependencies.makeMeetCreateViewController(coordinator: self)
        self.navigationController.presentWithTransition(meetCreateVC)
    }
    
    func completed(with meet: Meet) {
        self.dismiss(completion: { [weak self] in
            guard let meetId = meet.meetSummary?.id else { return }
            self?.presentMeetDetailView(meetId: meetId).self
        })
    }
}

// MARK: - Flow
extension HomeFlowCoordinator {
    
    private func presentMeetDetailView(meetId: Int) {
        let meetDetailCoordinator = dependencies.makeMeetDetailFlowCoordinator(meetId: meetId)
        self.start(coordinator: meetDetailCoordinator)
        self.navigationController.presentWithTransition(meetDetailCoordinator.navigationController)
    }
    
    // MARK: - 일정생성
    func presentPlanCreateView(meetList: [MeetSummary]) {
        let planCreateFlowCoordinator = dependencies
            .makePlanCreateFlowCoordinator(meetList: meetList,
                                           completionHandler: { [weak self] plan in
                guard let self,
                      let planId = plan.id else { return }
                self.presentPlanDetailView(planId: planId, type: .plan)
            })
        self.start(coordinator: planCreateFlowCoordinator)
        self.navigationController.presentWithTransition(planCreateFlowCoordinator.navigationController)
    }
    
    // MARK: - 일정상세
    func presentPlanDetailView(planId: Int, type: PlanDetailType) {
        let planDetailCoordinator = dependencies.makePlanDetailFlowCoordinator(postId: planId, type: type)
        self.start(coordinator: planDetailCoordinator)
        self.navigationController.presentWithTransition(planDetailCoordinator.navigationController)
    }
    
    // MARK: - 알림 리스트
    func presentNotifyView() {
        let notifyCoordinator = dependencies.makeNotifyListFlowCoordinator()
        self.start(coordinator: notifyCoordinator)
        self.navigationController.presentWithTransition(notifyCoordinator.navigationController)
    }
}

// MARK: - Tabbar
extension HomeFlowCoordinator {
    func pushCalendarView(lastRecentDate: Date) {
        guard let mainCoordination = self.parentCoordinator as? MainCoordination else { return }
        mainCoordination.showCalendar(startingFrom: lastRecentDate)
    }
}


