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
    // 공지 GET 단건 API가 없어 진입 시 Notice 객체 스냅샷을 함께 넘긴다.
    // isCreator는 page menu(수정/삭제 vs 신고) 분기에 사용.
    case detail(notice: Notice, isCreator: Bool)
    case list(meetId: Int, isCreator: Bool)
}

protocol NoticeFlowCoordination: AnyObject {
    func pushNoticeDetail(notice: Notice, isCreator: Bool)
    func pushComposeView()
    // 공지 수정 화면 진입. Compose 화면을 .edit 모드로 재사용.
    func pushEditView(notice: Notice)
    // 프로필 이미지 확대 (PhotoBookViewController) — present modal.
    func presentProfileImage(name: String?, imagePath: String?)
    // 현재 push된 화면 한 단계 pop (Compose 작성/수정 완료 후, Detail 삭제 후 등)
    func popCurrentView()
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
        case .detail(let notice, let isCreator):
            let vc = dependencies.makeNoticeDetailViewController(notice: notice,
                                                                 isCreator: isCreator,
                                                                 coordinator: self)
            self.pushWithTracking(vc, animated: false)

        case .list(let meetId, let isCreator):
            let vc = dependencies.makeNoticeListViewController(meetId: meetId,
                                                               isCreator: isCreator,
                                                               coordinator: self)
            self.pushWithTracking(vc, animated: false)
        }
    }
}

// MARK: - Push Flows
extension NoticeFlowCoordinator {
    // 리스트 셀 탭 → 상세
    func pushNoticeDetail(notice: Notice, isCreator: Bool) {
        let vc = dependencies.makeNoticeDetailViewController(notice: notice,
                                                             isCreator: isCreator,
                                                             coordinator: self)
        self.pushWithTracking(vc, animated: true)
    }

    // 리스트 작성 버튼 → 작성 (create 모드)
    func pushComposeView() {
        guard case .list(let meetId, _) = entry else { return }
        let vc = dependencies.makeNoticeComposeViewController(mode: .create(meetId: meetId),
                                                              coordinator: self)
        self.pushWithTracking(vc, animated: true)
    }

    // 상세 메뉴 "공지 수정" → 작성 화면 재사용 (edit 모드, content prefill)
    func pushEditView(notice: Notice) {
        let vc = dependencies.makeNoticeComposeViewController(mode: .edit(notice: notice),
                                                              coordinator: self)
        self.pushWithTracking(vc, animated: true)
    }
}

// MARK: - Present
extension NoticeFlowCoordinator {
    // 프로필 이미지 확대 — PhotoBookViewController modal present
    func presentProfileImage(name: String?, imagePath: String?) {
        let vc = dependencies.makeProfileImageViewController(title: name,
                                                             imagePath: imagePath)
        self.presentWithTracking(vc)
    }
}

// MARK: - Pop
extension NoticeFlowCoordinator {
    func popCurrentView() {
        self.navigationController.popViewController(animated: true)
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
