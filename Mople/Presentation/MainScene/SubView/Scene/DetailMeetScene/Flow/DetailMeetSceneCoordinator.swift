//
//  GroupDetailScene.swift
//  Mople
//
//  Created by CatSlave on 1/5/25.
//

import UIKit

protocol DetailMeetCoordination {
    
}

final class DetailMeetSceneCoordinator: BaseCoordinator, DetailMeetCoordination {
    
    private let dependencies: DetailMeetSceneDependencies
    
    init(dependencies: DetailMeetSceneDependencies,
         navigationController: UINavigationController) {
        self.dependencies = dependencies
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        let vc = dependencies.makeDetailGroupViewController(coordinator: self)
        navigationController.pushViewController(vc, animated: false)
    }
}
