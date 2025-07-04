//
//  GroupDetailScene.swift
//  Mople
//
//  Created by CatSlave on 1/5/25.
//

import UIKit

protocol MeetDetailCoordination: AnyObject {
    
    // MARK: - Default View
    func swicthPlanListPage(isFuture: Bool)
    
    // MARK: - Move To View
    func pushMeetSetupView(meet: Meet)
    func presentPhotoView(title: String?,
                          imagePath: String?)
    
    // MARK: - Move To Flow
    func presentPlanCreateView(meet: MeetSummary)
    func presentPlanDetailView(postId: Int,
                               type: PostType)
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
        self.pushWithTracking(detailMeetVC!, animated: false)
        setPageViews()
    }
    
    private func setPageViews() {
        planListVC = dependencies.makeMeetPlanListViewController()
        reviewListVC = dependencies.makeMeetReviewListViewController()
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

// MARK: - Meet Photo View
extension MeetDetailSceneCoordinator {
    func presentPhotoView(title: String?,
                          imagePath: String?) {
        let vc = dependencies.makeMeetImageViewController(imagePath: imagePath,
                                                          title: title,
                                                          coordinator: self)
        self.presentWithTracking(vc)
    }
}

// MARK: - Meet Setup View
extension MeetDetailSceneCoordinator: MeetSetupCoordination {
    func pushMeetSetupView(meet: Meet) {
        let vc = dependencies.makeMeetSetupViewController(meet: meet,
                                                          coordinator: self)
        self.pushWithTracking(vc, animated: true)
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
        self.pushWithTracking(vc, animated: true)
    }
}

// MARK: - MemberList View
extension MeetDetailSceneCoordinator: MemberListViewCoordination {
    func presentPhotoView(imagePath: String?) {
        self.presentPhotoView(title: nil,
                              imagePath: imagePath)
    }
    
    func pushMemberListView() {
        let vc = dependencies.makeMemberListViewController(coordinator: self)
        self.pushWithTracking(vc, animated: true)
    }
}

// MARK: - Plan Create Flow
extension MeetDetailSceneCoordinator {
    func presentPlanCreateView(meet: MeetSummary) {
        let planCreateFlowCoordinator = dependencies.makePlanCreateFlowCoordinator(meet: meet,
                                                                                   completion: { [weak self] plan in
            guard let self,
                  let planId = plan.id else { return }
            self.presentPlanDetailView(postId: planId,
                                       type: .plan)
        })
        start(coordinator: planCreateFlowCoordinator)
        self.present(planCreateFlowCoordinator.navigationController)
    }
}

// MARK: - Plan Detail Flow
extension MeetDetailSceneCoordinator {
    func presentPlanDetailView(postId: Int,
                            type: PostType) {
        let planDetailFlowCoordinator = dependencies.makePostDetailFlowCoordinator(postId: postId,
                                                                                   type: type)
        start(coordinator: planDetailFlowCoordinator)
        self.present(planDetailFlowCoordinator.navigationController)
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
