//
//  DetailGroupDIContainer.swift
//  Mople
//
//  Created by CatSlave on 1/5/25.
//

import UIKit

protocol DetailMeetSceneDependencies {
    func makeDetailGroupViewController(coordinator: DetailMeetCoordination) -> DetailMeetViewController
}

final class DetailGroupSceneDIContainer: DetailMeetSceneDependencies {
    
    private let appNetworkService: AppNetworkService
    private let groupID: Int
    
    init(appNetworkService: AppNetworkService,
         groupID: Int) {
        self.appNetworkService = appNetworkService
        self.groupID = groupID
    }
    
    func makeDetailGroupCoordinator(navigationController: UINavigationController) -> DetailMeetSceneCoordinator {
        return .init(dependencies: self,
                     navigationController: navigationController)
    }
}

extension DetailGroupSceneDIContainer {
    func makeDetailGroupViewController(coordinator: DetailMeetCoordination) -> DetailMeetViewController {
        return .init(title: nil,
                     reactor: makeDetailGroupViewReactor(coordinator: coordinator))
    }
    
    private func makeDetailGroupViewReactor(coordinator: DetailMeetCoordination) -> DetailMeetViewReactor {
        return .init(coordinator: coordinator,
                     groupID: groupID)
    }
}
