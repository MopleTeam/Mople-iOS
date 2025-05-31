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
    func pushReviewEditView(review: Review)
    func presentPhotoView(title: String?,
                       index: Int,
                       imagePaths: [String],
                       defaultType: UIImageView.DefaultImageType)
    func presentPlanEditFlow(plan: Plan)
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
        let vc = dependencies.makeMemberListViewController(coordinator: self)
        self.pushWithTracking(vc, animated: true)
    }
    
    func presentPhotoView(imagePath: String?) {
        let imagePaths = [imagePath].compactMap { $0 }
        self.presentPhotoView(title: nil,
                              index: 0,
                              imagePaths: imagePaths,
                              defaultType: .user)
    }
}

// MARK: - Review Edit View
extension PostDetailFlowCoordinator: ReviewEditViewCoordination {
    func pushReviewEditView(review: Review) {
        let vc = dependencies.makeReviewEditViewController(review: review,
                                                           coordinator: self)
        self.pushWithTracking(vc)
    }
}

// MARK: - Photo View
extension PostDetailFlowCoordinator {
    func presentPhotoView(title: String?,
                          index: Int,
                          imagePaths: [String],
                          defaultType: UIImageView.DefaultImageType) {
        let vc = dependencies.makePhotoBookViewController(title: title,
                                                          imagePaths: imagePaths,
                                                          defaultType: defaultType,
                                                          coordinator: self)
        vc.selectedIndex = index
        self.presentWithTracking(vc)
    }
}

// MARK: - Detail Place View
extension PostDetailFlowCoordinator: PlaceDetailCoordination {
    func pushPlaceDetailView(place: PlaceInfo) {
        let vc = dependencies.makePlaceDetailViewController(place: place,
                                                              coordinator: self)
        self.pushWithTracking(vc, animated: true)
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
