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
    func showDetailPlaceView(place: PlaceInfo)
    func completedProcess(selectedPlace: PlaceInfo)
    func endProcess()
}

final class SearchPlaceFlowCoordinator: BaseCoordinator, SearchPlaceFlowAction {
    
    private let dependencies: SearchPlaceSceneDependencies
    private var searchLoactionVC: SearchPlaceViewController?
    private var searchResultVC: SearchResultViewController?
    private var detailPlaceVC: DetailPlaceViewController?
    
    init(navigationController: UINavigationController,
         dependencies: SearchPlaceSceneDependencies) {
        print(#function, #line, "LifeCycle Test SearchPlaceFlowCoordinator Created" )
        self.dependencies = dependencies
        super.init(navigationController: navigationController)
    }
    
    deinit {
        print(#function, #line, "LifeCycle Test SearchPlaceFlowCoordinator Deinit" )
    }
    
    override func start() {
        searchLoactionVC = dependencies.makeSearchLocationViewController(flow: self)
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
    func showDetailPlaceView(place: PlaceInfo) {
        guard let searchLoactionVC,
              detailPlaceVC == nil else { return }
        let container = searchLoactionVC.detailPlaceContainer
        let vc = dependencies.makeDetailLocationViewController(place: place)
        detailPlaceVC = vc
        searchLoactionVC.add(child: vc, container: container)
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
    
    func completedProcess(selectedPlace: PlaceInfo) {
        (self.parentCoordinator as? PlaceSelectionDelegate)?.didSelectPlace(selectedPlace)
        self.endFlow()
    }
    
    private func endFlow() {
        self.navigationController.dismiss(animated: false) { [weak self] in
            guard let self else { return }
            self.clearUp()
            self.parentCoordinator?.didFinish(coordinator: self)
        }
    }
}
