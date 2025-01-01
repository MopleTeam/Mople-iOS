//
//  SearchLocationViewReactor.swift
//  Mople
//
//  Created by CatSlave on 12/25/24.
//

import Foundation
import ReactorKit

final class SearchPlaceReactor: Reactor {
    
    struct PlaceSearchResult {
        let places: [PlaceInfo]
        let isCached: Bool
    }
    
    enum Action {
        case fetchCahcedPlace
        case searchPlace(query: String?)
        case showDetailPlace(index: Int)
        case deletePlace(index: Int)
        case endProcess
        case selectedPlace(_ place: PlaceInfo)
    }
    
    enum Mutation {
        case updatePlace(_ result: PlaceSearchResult)
        case notifyLoadingState(_ isLoading: Bool)
    }
    
    struct State {
        @Pulse var searchResult: PlaceSearchResult?
        @Pulse var isLoading: Bool = false
    }
    
    var initialState: State = State()
    
    private let searchUseCase: SearchLoaction
    private let queryStorage: SearchedPlaceStorage
    private weak var flow: SearchPlaceFlowAction?
    
    init(searchLocationUseCase: SearchLoaction,
         queryStorage: SearchedPlaceStorage,
         flow: SearchPlaceFlowAction) {
        print(#function, #line, "LifeCycle Test SearchLocationReactor Created" )
        self.searchUseCase = searchLocationUseCase
        self.queryStorage = queryStorage
        self.flow = flow
        action.onNext(.fetchCahcedPlace)
    }
    
    deinit {
        print(#function, #line, "LifeCycle Test SearchLocationReactor Deinit" )
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchCahcedPlace:
            return self.fetchCahcedPlace()
        case let .searchPlace(query):
            return self.searchLocation(query: query)
        case let .showDetailPlace(index):
            return self.selectedPlace(index: index)
        case let .deletePlace(index):
            return self.deleteHistory(index: index)
        case .endProcess:
            self.flow?.endFlow(place: nil)
            return .empty()
        case .selectedPlace(_):
            return .empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case let .updatePlace(result):
            newState.searchResult = result
        case let .notifyLoadingState(isLoading):
            newState.isLoading = isLoading
       
        }
        
        return newState
    }
    
}

extension SearchPlaceReactor {
    private func fetchCahcedPlace() -> Observable<Mutation> {
        let places = queryStorage.readPlaces()
        self.updateHistoryVisibility(result: places)
        return .just(Mutation.updatePlace(.init(places: places, isCached: true)))
    }
    
    private func searchLocation(query: String?) -> Observable<Mutation> {
        
        #warning("정규식 검사")
        guard let query else { return .empty() }
        
        let loadingStart = Observable.just(Mutation.notifyLoadingState(true))
        
        #warning("에러 처리")
        let requestSearch = searchUseCase.requestSearchLocation(query: query)
            .asObservable()
            .filter({ [weak self] response in
                let isEmpty = response.result.isEmpty
                self?.updateSearchResultVisibility(result: response.result)
                return !isEmpty
            })
            .map { Mutation.updatePlace(.init(places: $0.result, isCached: false)) }
        
        let loadingStop = Observable.just(Mutation.notifyLoadingState(false))
        
        return Observable.concat([loadingStart,
                                  requestSearch,
                                  loadingStop])
    }
        
    private func selectedPlace(index: Int) -> Observable<Mutation> {
        guard let result = currentState.searchResult,
              !result.isCached,
              result.places.count > index,
              let selectedPlace = result.places[safe: index] else { return .empty() }
              
        print(#function, #line, "#1 selectedPlace : \(index)" )
        queryStorage.addPlace(selectedPlace)
        return .empty()
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
        self.flow?.updateEmptyViewVisibility(shouldShow: false)
        self.flow?.updateSearchResultViewVisibility(shouldShow: !result.isEmpty)
    }
    
    /// 검색결과 유무에 따라서 뷰 표시
    /// - 검색결과 유무
    ///     - 데이터 O : 결과창 표시
    ///     - 데이터 X : empty view 표시
    private func updateSearchResultVisibility(result: [PlaceInfo]) {
        self.flow?.updateEmptyViewVisibility(shouldShow: result.isEmpty)
        self.flow?.updateSearchResultViewVisibility(shouldShow: !result.isEmpty)
    }
}
