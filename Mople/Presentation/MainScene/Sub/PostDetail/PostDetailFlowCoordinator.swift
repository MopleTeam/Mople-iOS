//
//  PlanDetailFlowCoordinator.swift
//  Mople
//
//  Created by CatSlave on 1/11/25.
//

import UIKit

protocol PostDetailCoordination: AnyObject {
    func pushMemberListView(postId: Int)
    func pushPlaceDetailView(place: PlaceInfo)
    func pushPhotoView(index: Int,
                       imagePaths: [String])
    func presentPlanEditFlow(plan: Plan)
    func presentReviewEditFlow(review: Review)
    func endFlow()
}

final class PostDetailFlowCoordinator: BaseCoordinator, PostDetailCoordination {

    private let dependencies: PostDetailSceneDependencies
    
    init(dependencies: PostDetailSceneDependencies,
         navigationController: AppNaviViewController) {
        self.dependencies = dependencies
        super.init(navigationController: navigationController)
        setDismissGestureCompletion()
    }
    
    override func start() {
        let planDetailVC = makePlanDetailViewController()
        self.pushWithTracking(planDetailVC, animated: false)
    }
}

// MARK: - Default View
extension PostDetailFlowCoordinator {
    private func makePlanDetailViewController() -> PostDetailViewController {
        return dependencies.makePlanDetailViewController(coordinator: self)
    }
}

// MARK: - Member List View
extension PostDetailFlowCoordinator: MemberListViewCoordination {
    func pushMemberListView(postId: Int) {
        let view = dependencies.makeMemberListViewController(coordinator: self)
        self.pushWithTracking(view, animated: true)
    }
}

// MARK: - Photo View
extension PostDetailFlowCoordinator {
    func pushPhotoView(index: Int,
                       imagePaths: [String]) {
        let view = dependencies.makePhotoBookViewController(imagePaths: imagePaths,
                                                            index: index,
                                                            coordinator: self)
        self.navigationController.present(view, animated: true)
    }
}

// MARK: - Detail Place View
extension PostDetailFlowCoordinator: PlaceDetailCoordination {
    func pushPlaceDetailView(place: PlaceInfo) {
        let view = dependencies.makePlaceDetailViewController(place: place,
                                                              coordinator: self)
        self.pushWithTracking(view, animated: true)
    }
}

// MARK: - Flow
extension PostDetailFlowCoordinator {
    
    // 일정 수정 플로우
    func presentPlanEditFlow(plan: Plan) {
        let flow = dependencies.makePlanEditFlowCoordiantor(plan: plan)
        self.start(coordinator: flow)
        self.present(flow.navigationController)
    }
    
    // 리뷰 수정 플로우
    func presentReviewEditFlow(review: Review) {
        let flow = dependencies.makeReviewEditFlowCoordinator(review: review)
        self.start(coordinator: flow)
        self.present(flow.navigationController)
    }
}

// MARK: - End Flow
extension PostDetailFlowCoordinator {
    func endFlow() {
        self.navigationController.dismiss(animated: true) { [weak self] in
            guard let self else { return }
            self.clearUp()
            self.parentCoordinator?.didFinish(coordinator: self)
        }
    }
}
