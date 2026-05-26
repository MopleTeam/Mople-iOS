//
//  NoticeSceneDIContainer.swift
//  Mople
//
//  Created by CatSlave on 5/26/26.
//

import UIKit
import SwiftUI
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

// MARK: - View Factories (SwiftUI + UIHostingController)
extension NoticeSceneDIContainer {

    @MainActor
    func makeNoticeListViewController(meetId: Int,
                                      isCreator: Bool,
                                      coordinator: NoticeFlowCoordination) -> UIViewController {
        let view = NoticeListView(
            meetId: meetId,
            isCreator: isCreator,
            onComposeTap: { [weak coordinator] in
                coordinator?.pushComposeView()
            }
        )
        return UIHostingController(rootView: view)
    }

    @MainActor
    func makeNoticeDetailViewController(noticeId: Int) -> UIViewController {
        let view = NoticeDetailView(noticeId: noticeId)
        return UIHostingController(rootView: view)
    }

    @MainActor
    func makeNoticeComposeViewController(meetId: Int) -> UIViewController {
        let view = NoticeComposeView(meetId: meetId)
        return UIHostingController(rootView: view)
    }
}
