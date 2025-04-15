//
//  GroupDetailScene.swift
//  Mople
//
//  Created by CatSlave on 1/5/25.
//

import UIKit

protocol MeetDetailCoordination: AnyObject {
    func swicthPlanListPage(isFuture: Bool)
    func pushMeetSetupView(meet: Meet)
    func pushPlanDetailView(postId: Int,
                            type: PlanDetailType)
    func endFlow()
}

final class MeetDetailSceneCoordinator: BaseCoordinator, MeetDetailCoordination {
    
    private let dependencies: MeetDetailSceneDependencies
    private var detailMeetVC: MeetDetailViewController?
    private var planListVC: MeetPlanListViewController?
    private var reviewListVC: MeetReviewListViewController?
    
    init(dependencies: MeetDetailSceneDependencies,
         navigationController: AppNaviViewController) {
        self.dependencies = dependencies
        super.init(navigationController: navigationController)
        setDismissGestureCompletion()
    }
    
    override func start() {
        detailMeetVC = dependencies.makeMeetDetailViewController(coordinator: self)
        navigationController.pushViewController(detailMeetVC!, animated: false)
        setPageViews()
    }
    
    private func setPageViews() {
        planListVC = dependencies.makeMeetPlanListViewController()
        reviewListVC = dependencies.makeMeetReviewListViewController(coordinator: self)
        detailMeetVC?.pageController.setViewControllers([planListVC!], direction: .forward, animated: false)
    }
}

// MARK: - PageControl Setup
extension MeetDetailSceneCoordinator {
    func swicthPlanListPage(isFuture: Bool) {
        guard let vc = isFuture ? planListVC : reviewListVC,
              let currentVC = self.detailMeetVC?.pageController.viewControllers?.first,
              vc != currentVC else { return }
        
        let direction: UIPageViewController.NavigationDirection = isFuture ? .reverse : .forward
        
        detailMeetVC?.pageController.setViewControllers([vc], direction: direction, animated: true)
    }
}

// MARK: - Meet Setup View
extension MeetDetailSceneCoordinator: MeetSetupCoordination {
    func pushMeetSetupView(meet: Meet) {
        let vc = dependencies.makeMeetSetupViewController(meet: meet,
                                                          coordinator: self)
        navigationController.pushViewController(vc, animated: true)
    }
}

// MARK: - Meet Edit View
extension MeetDetailSceneCoordinator: MeetCreateViewCoordination {
    func completed(with meet: Meet) {
        self.dismiss(completion: nil)
    }
    
    func pushEditMeetView(previousMeet: Meet) {
        let vc = dependencies.makeEditMeetViewController(previousMeet: previousMeet,
                                                         coordinator: self)
        
        navigationController.pushViewController(vc, animated: true)
    }
}

// MARK: - MemberList View
extension MeetDetailSceneCoordinator: MemberListViewCoordination {
    func pushMemberListView() {
        let vc = dependencies.makeMemberListViewController(coordinator: self)
        navigationController.pushViewController(vc, animated: true)
    }
}

// MARK: - Plan Detail Flow
extension MeetDetailSceneCoordinator {
    func pushPlanDetailView(postId: Int,
                            type: PlanDetailType) {
        let planDetailFlowCoordinator = dependencies.makePlanDetailFlowCoordinator(postId: postId,
                                                                                   type: type)
        start(coordinator: planDetailFlowCoordinator)
        navigationController.presentWithTransition(planDetailFlowCoordinator.navigationController)
    }
}

// MARK: - End Flow
extension MeetDetailSceneCoordinator {
    func endFlow() {
        navigationController.dismiss(animated: true) { [weak self] in
            self?.clear()
        }
    }
    
    private func clear() {
        clearUp()
        parentCoordinator?.didFinish(coordinator: self)
    }
}
