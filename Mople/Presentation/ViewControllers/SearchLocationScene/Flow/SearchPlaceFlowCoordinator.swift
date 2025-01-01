//
//  SearchLocationFlowCoordinator.swift
//  Mople
//
//  Created by CatSlave on 12/24/24.
//

import UIKit

protocol SearchPlaceFlowAction: AnyObject {
    func updateSearchResultViewVisibility(shouldShow: Bool)
    func updateEmptyViewVisibility(shouldShow: Bool)
    func endFlow(place: PlaceInfo?)
}

final class SearchPlaceFlowCoordinator: BaseCoordinator, SearchPlaceFlowAction {
    
    private let dependencies: SearchPlaceSceneDependencies
    private var searchLoactionVC: SearchPlaceViewController?
    private var searchResultVC: SearchResultViewController?
    
    init(navigationController: UINavigationController,
         dependencies: SearchPlaceSceneDependencies) {
        print(#function, #line, "LifeCycle Test SearchLocationSceneCoordinator Created" )
        self.dependencies = dependencies
        super.init(navigationController: navigationController)
    }
    
    deinit {
        print(#function, #line, "LifeCycle Test SearchLocationSceneCoordinator Deinit" )
    }
    
    override func start() {
        searchLoactionVC = dependencies.makeSearchLocationViewController(flow: self)
        self.navigationController.pushViewController(searchLoactionVC!, animated: false)
    }
}

extension SearchPlaceFlowCoordinator {
    func updateSearchResultViewVisibility(shouldShow: Bool) {
        if shouldShow {
            showSearchResult()
        } else {
            closeSearchResult()
        }
    }
    
    func updateEmptyViewVisibility(shouldShow: Bool) {
        searchLoactionVC?.startView.isHidden = shouldShow
        searchLoactionVC?.emptyView.isHidden = !shouldShow
    }
}

// MARK: - Helper
extension SearchPlaceFlowCoordinator {
    private func showSearchResult() {
        guard let searchLoactionVC,
              searchResultVC == nil else { return }
        let container = searchLoactionVC.resultVCContainer
        let vc = dependencies.makeSearchResultViewController()
        searchResultVC = vc
        searchLoactionVC.add(child: vc, container: container)
        container.isHidden = false
        print(#function, #line, "#1 : 성공" )
    }
    
    private func closeSearchResult() {
        guard searchResultVC != nil else { return }
        searchResultVC?.remove()
        searchResultVC = nil
        searchLoactionVC?.resultVCContainer.isHidden = true
    }
}

// MARK: - End Flow
extension SearchPlaceFlowCoordinator {
    func endFlow(place: PlaceInfo?) {
        guard let parent = self.parentCoordinator as? PlaceSelectionDelegate else { return }
        parent.didSelectPlace(place)
        self.navigationController.dismiss(animated: false) { [weak self] in
            guard let self else { return }
            self.clearUp()
            self.parentCoordinator?.didFinish(coordinator: self)
        }
    }
}
