//
//  ProfileSetupViewModel.swift
//  Group
//
//  Created by CatSlave on 8/25/24.
//

import Foundation
import ReactorKit

protocol ProfileViewModel {
    func transform(input: ViewModelInput) -> LoginOutput
}

protocol testModel: Reactor {
    var profileSetup: ProfileSetup { get }
}

final class ProfileSetupViewModel: Reactor {
    
    let profileSetup: ProfileSetup
    
    enum Action {
        case checkNickname(name: String)
    }
    
    enum Mutation {
        case nameCheck(isOverlap: Bool)
    }
    
    struct State {
        @Pulse var nameOverlap: Bool = false
//        var searchTerm: String? = nil
//        
//        var completedTodos: [Int] {
//            todos.filter({ $0.isDone ?? false }).compactMap({ $0.id })
//        }
//        
//        @Pulse var todos: [Todo] = []
//        @Pulse var pageInfo: Meta? = nil
//        @Pulse var isLoading: Bool = false
//        @Pulse var refreshEnded: Void? = nil
//        @Pulse var resetSearchTerm: Void? = nil
//        @Pulse var errorMessage: String? = nil
//        @Pulse var hasContent: Bool = true
//        @Pulse var addedTodo: Void? = nil
    }
    
    var initialState: State = State()
    
    init(profileSetup: ProfileSetup) {
        self.profileSetup = profileSetup
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
        switch action {
        case .checkNickname(let name):
            return checkName(name: name)
        }

//        case .fetchMore:
//            guard let pageInfo = self.currentState.pageInfo,
//                  let page = pageInfo.currentPage,
//                  !self.currentState.todos.isEmpty,
//                  pageInfo.hasNext() else {
//                return Observable.empty()
//            }
//            
//            return fetchMore(page)
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case .nameCheck(let isOverlap):
            newState.nameOverlap = isOverlap
        }
  
        return newState
    }
    
    func handleError(state: State, err: Error) -> State {
        var newState = state
//        guard let apiError = err as? TodosAPI_Rx.ApiError else {
//            newState.errorMessage = TodosAPI_Rx.ApiError.unknown(err).info
//            return newState
//        }
//        
//        switch apiError {
//        case .noContent:
//            newState.hasContent = false
//            newState.pageInfo = nil
//        case .errResponseFromServer(let errorResponse):
//            if let message = errorResponse?.message {
//                newState.errorMessage = message
//            }
//        case .incompleteTask:
//            newState.errorMessage = apiError.info
//        default:
//            newState.errorMessage = apiError.info
//        }
        
        return newState
    }
}

extension ProfileSetupViewModel {
    
    private func checkName(name: String) -> Observable<Mutation> {
        
        let nameOverlap = profileSetup.checkNickName(name: name)
            .map({ Mutation.nameCheck(isOverlap: $0)})
            .asObservable()
        
        return nameOverlap
    }
    
}
