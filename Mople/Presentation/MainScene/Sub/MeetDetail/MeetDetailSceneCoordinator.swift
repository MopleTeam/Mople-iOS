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
    func pushPlanDetailView(planId: Int)
    func popView()
    func endFlow()
}

final class MeetDetailSceneCoordinator: BaseCoordinator, MeetDetailCoordination {
    private let dependencies: MeetDetailSceneDependencies
    private var detailMeetVC: DetailMeetViewController?
    private var futurePlanListVC: FuturePlanListViewController?
    private var pastPlanListVC: PastPlanListViewController?
    
    init(dependencies: MeetDetailSceneDependencies,
         navigationController: AppNaviViewController) {
        self.dependencies = dependencies
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        detailMeetVC = dependencies.makeMeetDetailViewController(coordinator: self)
        navigationController.pushViewController(detailMeetVC!, animated: false)
        setPageViews()
    }
    
    private func setPageViews() {
        futurePlanListVC = dependencies.makeFuturePlanListViewController(coordinator: self)
        pastPlanListVC = dependencies.makePastPlanListViewController()
        self.detailMeetVC?.pageController.setViewControllers([futurePlanListVC!], direction: .forward, animated: false)
    }
    
    override func dismiss() {
        self.navigationController.dismiss(animated: true)
    }
    
    override func pop() {
        self.navigationController.popViewController(animated: true)
    }
}

// MARK: - PageControl Setup
extension MeetDetailSceneCoordinator {
    func swicthPlanListPage(isFuture: Bool) {
        guard let vc = isFuture ? futurePlanListVC : pastPlanListVC,
              let currentVC = self.detailMeetVC?.pageController.viewControllers?.first,
              vc != currentVC else { return }
        
        let direction: UIPageViewController.NavigationDirection = isFuture ? .reverse : .forward
        
        self.detailMeetVC?.pageController.setViewControllers([vc], direction: direction, animated: true)
    }
}

// MARK: - Push & Pop
extension MeetDetailSceneCoordinator {
    func pushMeetSetupView(meet: Meet) {
        let vc = dependencies.makeMeetSetupViewController(meet: meet,
                                                          coordinator: self)
        self.navigationController.pushViewController(vc, animated: true)
    }
    
    func popView() {
        self.pop()
    }
}

// MARK: - Push Flow
extension MeetDetailSceneCoordinator {
    func pushPlanDetailView(planId: Int) {
        let planDetailFlowCoordinator = dependencies.makePlanDetailFlowCoordinator(planId: planId)
        self.start(coordinator: planDetailFlowCoordinator)
        self.navigationController.presentWithTransition(planDetailFlowCoordinator.navigationController)
    }
}

// MARK: - End Flow
extension MeetDetailSceneCoordinator {
    func endFlow() {
        self.navigationController.dismiss(animated: true) { [weak self] in
            self?.clear()
        }
    }
    
    private func clear() {
        self.clearUp()
        self.parentCoordinator?.didFinish(coordinator: self)
    }
}
