//
//  NoticeFlowCoordinator.swift
//  Mople
//
//  Created by CatSlave on 5/26/26.
//

import UIKit
import Domain

// 모임 공지 Flow.
// MeetDetail에서 두 가지 진입점(미리보기 카드 → 상세, 확성기 → 리스트)을 가지며
// 리스트 안에서 작성 화면(모임장 전용)으로 push.
enum NoticeFlowEntry {
    case detail(noticeId: Int)
    case list(meetId: Int, isCreator: Bool)
}

protocol NoticeFlowCoordination: AnyObject {
    func pushComposeView()
    func endFlow()
}

final class NoticeFlowCoordinator: BaseCoordinator, NoticeFlowCoordination {

    private let dependencies: NoticeSceneDependencies
    private let entry: NoticeFlowEntry

    init(dependencies: NoticeSceneDependencies,
         entry: NoticeFlowEntry,
         navigationController: AppNaviViewController) {
        self.dependencies = dependencies
        self.entry = entry
        super.init(navigationController: navigationController)
        setDismissGestureCompletion()
    }

    override func start() {
        switch entry {
        case .detail(let noticeId):
            let vc = dependencies.makeNoticeDetailViewController(noticeId: noticeId)
            self.pushWithTracking(vc, animated: false)

        case .list(let meetId, let isCreator):
            let vc = dependencies.makeNoticeListViewController(meetId: meetId,
                                                               isCreator: isCreator,
                                                               coordinator: self)
            self.pushWithTracking(vc, animated: false)
        }
    }
}

// MARK: - Compose Flow (리스트 → 작성)
extension NoticeFlowCoordinator {
    func pushComposeView() {
        guard case .list(let meetId, _) = entry else { return }
        let vc = dependencies.makeNoticeComposeViewController(meetId: meetId)
        self.pushWithTracking(vc, animated: true)
    }
}

// MARK: - End Flow
extension NoticeFlowCoordinator {
    func endFlow() {
        self.navigationController.dismiss(animated: true) { [weak self] in
            guard let self else { return }
            self.clearUp()
            self.parentCoordinator?.didFinish(coordinator: self)
        }
    }
}
