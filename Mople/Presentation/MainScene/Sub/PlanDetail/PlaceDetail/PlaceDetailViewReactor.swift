//
//  PlaceDetailVIewReactor.swift
//  Mople
//
//  Created by CatSlave on 2/3/25.
//

import ReactorKit

protocol PlaceDetailCoordination: AnyObject {
    func pop()
}

final class PlaceDetailViewReactor: Reactor {
    
    enum Action {
        case setPlace
        case endProcess
    }
    
    enum Mutation {
        case updatePlaceInfo(PlaceInfo?)
        case updateLoadingState(Bool)
        case catchError(Error)
    }
    
    struct State {
        @Pulse var placeInfo: PlaceInfo?
        @Pulse var isLoading: Bool = false
        @Pulse var error: Error?
    }
    
    var initialState: State = State()
    
    private let locationService: LocationService
    private var place: PlaceInfo
    private weak var coordinator: PlaceDetailCoordination?
    
    init(place: PlaceInfo,
         locationService: LocationService,
         coordinator: PlaceDetailCoordination) {
        self.place = place
        self.locationService = locationService
        self.coordinator = coordinator
        initalAction()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .setPlace:
            return updatePlaceInfo()
        case .endProcess:
            coordinator?.pop()
            return .empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case let .updatePlaceInfo(placeInfo):
            newState.placeInfo = placeInfo
        case let .updateLoadingState(isLoading):
            newState.isLoading = isLoading
        case .catchError:
            break
        }
        
        return newState
    }
    
    private func initalAction() {
        action.onNext(.setPlace)
    }
}

extension PlaceDetailViewReactor {
    private func updatePlaceInfo() -> Observable<Mutation> {
        let location = locationService.updateLocation()
            .flatMap({ [weak self] location -> Observable<Mutation> in
                guard let self else { return .empty() }
                place.updateDistance(userLocation: location)
                return .just(.updatePlaceInfo(place))
            })

        return requestWithLoading(task: location)
    }
}

// MARK: - 로딩
extension PlaceDetailViewReactor: LoadingReactor {
    func updateLoadingMutation(_ isLoading: Bool) -> Mutation {
        return .updateLoadingState(isLoading)
    }
    
    func catchErrorMutation(_ error: Error) -> Mutation {
        return .catchError(error)
    }
}
