//
//  NoticeSceneDIContainer.swift
//  Mople
//
//  Created by CatSlave on 5/26/26.
//

import UIKit
import Domain
import Data

protocol NoticeSceneDependencies {
    func makeNoticeListViewController(meetId: Int,
                                      isCreator: Bool,
                                      coordinator: NoticeFlowCoordination) -> UIViewController
    func makeNoticeDetailViewController(noticeId: Int) -> UIViewController
    func makeNoticeComposeViewController(meetId: Int) -> UIViewController
}

final class NoticeSceneDIContainer: BaseContainer, NoticeSceneDependencies {

    private let entry: NoticeFlowEntry

    init(appNetworkService: AppNetworkService,
         commonFactory: ViewDependencies,
         userSession: UserSessionProvider,
         entry: NoticeFlowEntry) {
        self.entry = entry
        super.init(appNetworkService: appNetworkService,
                   commonFactory: commonFactory,
                   userSession: userSession)
    }

    func makeNoticeFlowCoordinator() -> NoticeFlowCoordinator {
        return .init(dependencies: self,
                     entry: entry,
                     navigationController: AppNaviViewController())
    }
}

// MARK: - View Factories
extension NoticeSceneDIContainer {

    func makeNoticeListViewController(meetId: Int,
                                      isCreator: Bool,
                                      coordinator: NoticeFlowCoordination) -> UIViewController {
        // 작성 진입점 연결은 본 구현 시 NoticeListViewReactor에 coordinator를 주입하는 방식으로 확장.
        return NoticeListViewController(meetId: meetId, isCreator: isCreator)
    }

    func makeNoticeDetailViewController(noticeId: Int) -> UIViewController {
        return NoticeDetailViewController(noticeId: noticeId)
    }

    func makeNoticeComposeViewController(meetId: Int) -> UIViewController {
        return NoticeComposeViewController(meetId: meetId)
    }
}
