//
//  PhotoListViewReactor.swift
//  Mople
//
//  Created by CatSlave on 1/21/25.
//

import ReactorKit

final class PhotoListViewReactor: Reactor {
    
    enum Action {
        case setImagePaths(_ imagePaths: [String])
    }
    
    enum Mutation {
        case updateImagePaths(_ imagePaths: [String])
    }
    
    struct State {
        @Pulse var imagePaths: [String] = []
    }
    
    var initialState: State = State()
    
    init(imagePaths: [String]) {
        action.onNext(.setImagePaths(imagePaths))
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .setImagePaths(imagePath):
            return .just(.updateImagePaths(imagePath))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case let .updateImagePaths(imaegPath):
            newState.imagePaths = imaegPath
        }
        
        return newState
    }
    
}

