//
//  SearchLocationViewReactor.swift
//  Mople
//
//  Created by CatSlave on 12/25/24.
//

import Foundation
import CoreLocation
import ReactorKit

enum SearchError: Error {
    case emptyQuery
    case unkonwnError
    
    var info: String {
        switch self {
        case .emptyQuery:
            return "검색어를 입력해주세요."
        case .unkonwnError:
            return "잠시 후 다시 시도해주세요."
        }
    }
}

final class SearchPlaceReactor: Reactor, LifeCycleLoggable {
    
    struct PlaceSearchResult {
        let places: [PlaceInfo]
        let isCached: Bool
    }
    
    enum Action {
        case updateUserLocation
        case fetchCahcedPlace
        case searchPlace(query: String?)
        case showDetailPlace(index: Int)
        case deletePlace(index: Int)
        case endProcess
        case selectedPlace(_ place: PlaceInfo)
    }
    
    enum Mutation {
        case setUserLocation(_ location: CLLocationCoordinate2D?)
        case setPlace(_ result: PlaceSearchResult)
        case notifyLoadingState(_ isLoading: Bool)
        case handleSearchError(error: SearchError?)
    }
    
    struct State {
        @Pulse var searchResult: PlaceSearchResult?
        @Pulse var userLocation: CLLocationCoordinate2D?
        @Pulse var error: SearchError?
        @Pulse var isLoading: Bool = false
    }
    
    var initialState: State = State()
    
    private let searchUseCase: SearchLoaction
    private let locationService: LocationService
    private let queryStorage: SearchedPlaceStorage
    private weak var coordinator: SearchPlaceCoordination?
    
    init(searchLocationUseCase: SearchLoaction,
         locationService: LocationService,
         queryStorage: SearchedPlaceStorage,
         coordinator: SearchPlaceCoordination) {
        self.searchUseCase = searchLocationUseCase
        self.locationService = locationService
        self.queryStorage = queryStorage
        self.coordinator = coordinator
        logLifeCycle()
        action.onNext(.fetchCahcedPlace)
        action.onNext(.updateUserLocation)
    }
    
    deinit {
        logLifeCycle()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .updateUserLocation:
            return updateUserLocation()
        case .fetchCahcedPlace:
            return self.fetchCahcedPlace()
        case let .searchPlace(query):
            return self.searchLocation(query: query)
        case let .showDetailPlace(index):
            return self.showDetailPlcae(index: index)
        case let .deletePlace(index):
            return self.deleteHistory(index: index)
        case .endProcess:
            self.coordinator?.endProcess()
            return .empty()
        case let .selectedPlace(place):
            self.coordinator?.completedProcess(selectedPlace: place)
            return .empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case let .setPlace(result):
            newState.searchResult = result
        case let .handleSearchError(err):
            newState.error = err
        case let .notifyLoadingState(isLoading):
            newState.isLoading = isLoading
        case let .setUserLocation(location):
            newState.userLocation = location
        }
        
        return newState
    }
    
}

extension SearchPlaceReactor {
    private func fetchCahcedPlace() -> Observable<Mutation> {
        let places = queryStorage.readPlaces()
        self.updateHistoryVisibility(result: places)
        return .just(Mutation.setPlace(.init(places: places, isCached: true)))
    }
    
    private func updateUserLocation() -> Observable<Mutation> {
        let loadingStart = Observable.just(Mutation.notifyLoadingState(true))
        
        let fetchUserLocation = locationService.updateLocation()
            .map { Mutation.setUserLocation($0) }
        
        let loadingStop = Observable.just(Mutation.notifyLoadingState(false))

        return .concat([loadingStart, fetchUserLocation, loadingStop])
    }
    
    private func searchLocation(query: String?) -> Observable<Mutation> {
        
        guard let query, !query.isEmpty else {
            return .just(.handleSearchError(error: SearchError.emptyQuery))
        }
        
        let loadingStart = Observable.just(Mutation.notifyLoadingState(true))
        
        let userLocation = currentState.userLocation
        #warning("에러 처리")
        let requestSearch = searchUseCase.requestSearchLocation(query: query,
                                                                x: userLocation?.longitude,
                                                                y: userLocation?.latitude)
            .asObservable()
            .observe(on: MainScheduler.instance)
            .filter({ [weak self] response in
                let isEmpty = response.result.isEmpty
                self?.updateSearchResultVisibility(result: response.result)
                return !isEmpty
            })
            .map { Mutation.setPlace(.init(places: $0.result, isCached: false)) }
        
        let loadingStop = Observable.just(Mutation.notifyLoadingState(false))
        
        return Observable.concat([loadingStart,
                                  requestSearch,
                                  loadingStop])
    }
        
    private func showDetailPlcae(index: Int) -> Observable<Mutation> {
        guard let result = currentState.searchResult,
              result.places.count > index,
              let selectedPlace = result.places[safe: index] else { return .empty() }
        coordinator?.showDetailPlaceView(place: selectedPlace)
        queryStorage.addPlace(selectedPlace)
        return Observable.just(()) // 화면 전환이 되기 전 검색어 업데이트 방지
            .delay(.milliseconds(300), scheduler: MainScheduler.instance)
            .flatMap { [weak self] _ -> Observable<Mutation> in
                guard let self,
                      result.isCached == true else { return .empty() }
                return self.fetchCahcedPlace()
            }
    }
    
    private func deleteHistory(index: Int) -> Observable<Mutation>  {
        guard let result = currentState.searchResult,
              result.isCached,
              result.places.count > index,
              let deletedHisotry = result.places[safe: index] else { return .empty() }
        
        queryStorage.deletePlace(deletedHisotry)
        return fetchCahcedPlace()
    }
}

// MARK: - Flow Update
extension SearchPlaceReactor {
    
    /// 캐시데이터가 있으면 검색결과 창 표시, 없다면 기본 화면 표시 (기본화면 startView)
    /// - updateEmptyViewVisibility false
    ///     - 검색어를 모두 지운 경우 히스토리 or 기본 화면 표시
    ///     - 검색결과가 없을 경우 emptyView가 표시되고 있음으로 false
    private func updateHistoryVisibility(result: [PlaceInfo]) {
        self.coordinator?.updateEmptyViewVisibility(shouldShow: false)
        self.coordinator?.updateSearchResultViewVisibility(shouldShow: !result.isEmpty)
    }
    
    /// 검색결과 유무에 따라서 뷰 표시
    /// - 검색결과 유무
    ///     - 데이터 O : 결과창 표시
    ///     - 데이터 X : empty view 표시
    private func updateSearchResultVisibility(result: [PlaceInfo]) {
        self.coordinator?.updateEmptyViewVisibility(shouldShow: result.isEmpty)
        self.coordinator?.updateSearchResultViewVisibility(shouldShow: !result.isEmpty)
    }
}
