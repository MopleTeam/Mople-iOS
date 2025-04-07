//
//  SearchLocationFlowCoordinator.swift
//  Mople
//
//  Created by CatSlave on 12/24/24.
//

import UIKit

protocol SearchPlaceCoordination: AnyObject {
    func updateSearchResultViewVisibility(shouldShow: Bool)
    func updateEmptyViewVisibility(shouldShow: Bool)
    func showDetailPlaceView(with place: PlaceInfo)
    func completed()
    func endProcess()
}

final class SearchPlaceFlowCoordinator: BaseCoordinator, SearchPlaceCoordination {
    
    private let dependencies: SearchPlaceSceneDependencies
    private var searchLoactionVC: SearchPlaceViewController?
    private var searchResultVC: SearchResultViewController?
    private var detailPlaceVC: PlaceSelectViewController?
    
    init(navigationController: AppNaviViewController,
         dependencies: SearchPlaceSceneDependencies) {
        self.dependencies = dependencies
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        searchLoactionVC = dependencies.makeSearchLocationViewController(coordinator: self)
        self.navigationController.pushViewController(searchLoactionVC!, animated: false)
    }
}

// MARK: - Empty View Visiblility
extension SearchPlaceFlowCoordinator {
    func updateEmptyViewVisibility(shouldShow: Bool) {
        searchLoactionVC?.startView.isHidden = shouldShow
        searchLoactionVC?.emptyView.isHidden = !shouldShow
    }
}

// MARK: - SearchResult View Visibility
extension SearchPlaceFlowCoordinator {
    func updateSearchResultViewVisibility(shouldShow: Bool) {
        if shouldShow {
            showSearchResult()
        } else {
            closeSearchResult()
        }
    }
    
    private func showSearchResult() {
        guard let searchLoactionVC,
              searchResultVC == nil else { return }
        let container = searchLoactionVC.placeListContainer
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
        searchLoactionVC?.placeListContainer.isHidden = true
    }
}

// MARK: - Detail Place View Visibility
extension SearchPlaceFlowCoordinator {
    func showDetailPlaceView(with place: PlaceInfo) {
        guard let searchLoactionVC,
              detailPlaceVC == nil else { return }
        let container = searchLoactionVC.detailPlaceContainer
        detailPlaceVC = dependencies.makePlaceSelectViewController(with: place)
        searchLoactionVC.add(child: detailPlaceVC!, container: container)
        container.isHidden = false
        print(#function, #line, "#1 : 성공" )
    }
    
    private func closeDetailPlace() {
        guard detailPlaceVC != nil else { return }
        detailPlaceVC?.remove()
        detailPlaceVC = nil
        searchLoactionVC?.detailPlaceContainer.isHidden = true
    }
}


// MARK: - End Flow
extension SearchPlaceFlowCoordinator {
    func endProcess() {
        if detailPlaceVC == nil {
            self.endFlow()
        } else {
            self.closeDetailPlace()
        }
    }
    
    func completed() {
        self.endFlow()
    }
    
    private func endFlow() {
        self.navigationController.dismiss(animated: true) { [weak self] in
            guard let self else { return }
            self.clearUp()
            self.parentCoordinator?.didFinish(coordinator: self)
        }
    }
}
