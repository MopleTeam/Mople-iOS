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
    private var searchPlaceVC: SearchPlaceViewController?
    private var searchResultVC: SearchResultViewController?
    private var detailPlaceVC: PlaceSelectViewController?
    
    init(navigationController: AppNaviViewController,
         dependencies: SearchPlaceSceneDependencies) {
        self.dependencies = dependencies
        super.init(navigationController: navigationController)
        setDismissGestureCompletion()
    }
    
    override func start() {
        searchPlaceVC = dependencies.makeSearchPlaceViewController(coordinator: self)
        self.pushWithTracking(searchPlaceVC!, animated: false)
    }
}

// MARK: - Empty View
extension SearchPlaceFlowCoordinator {
    func updateEmptyViewVisibility(shouldShow: Bool) {
        searchPlaceVC?.startView.isHidden = shouldShow
        searchPlaceVC?.emptyView.isHidden = !shouldShow
    }
}

// MARK: - SearchResult View
extension SearchPlaceFlowCoordinator {
    func updateSearchResultViewVisibility(shouldShow: Bool) {
        if shouldShow {
            showSearchResult()
        } else {
            closeSearchResult()
        }
    }
    
    private func showSearchResult() {
        guard let searchPlaceVC,
              searchResultVC == nil else { return }
        let container = searchPlaceVC.placeListContainer
        let vc = dependencies.makeSearchResultViewController()
        searchResultVC = vc
        searchPlaceVC.add(child: vc, container: container)
        container.isHidden = false
    }
    
    private func closeSearchResult() {
        guard searchResultVC != nil else { return }
        searchResultVC?.remove()
        searchResultVC = nil
        searchPlaceVC?.placeListContainer.isHidden = true
    }
}

// MARK: - Detail Place View
extension SearchPlaceFlowCoordinator {
    func showDetailPlaceView(with place: PlaceInfo) {
        guard let searchPlaceVC,
              detailPlaceVC == nil else { return }
        let container = searchPlaceVC.detailPlaceContainer
        detailPlaceVC = dependencies.makePlaceSelectViewController(with: place)
        searchPlaceVC.add(child: detailPlaceVC!, container: container)
        container.isHidden = false
        openPlaceDetailView()
    }
    
    private func closeDetailPlace() {
        guard detailPlaceVC != nil else { return }
        detailPlaceVC?.remove()
        detailPlaceVC = nil
        searchPlaceVC?.detailPlaceContainer.isHidden = true
        openSearchPlaceView()
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

// MARK: - Screen Tracking
extension SearchPlaceFlowCoordinator {
    private func openSearchPlaceView() {
        guard let searchPlaceVC else { return }
        ScreenTracking.track(with: searchPlaceVC)
    }
    
    private func openPlaceDetailView() {
        guard let detailPlaceVC else { return }
        ScreenTracking.track(with: detailPlaceVC)
    }
}
