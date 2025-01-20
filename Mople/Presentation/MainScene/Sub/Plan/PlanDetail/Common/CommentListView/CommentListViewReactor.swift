//
//  CommentListViewReactor.swift
//  Mople
//
//  Created by CatSlave on 1/16/25.
//

import ReactorKit

enum CommentViewError: Error {
    
}

final class CommentListViewReactor: Reactor, LifeCycleLoggable {
    
    enum Action {
        case loadCommentList(postId: Int)
    }
    
    enum Mutation {
        case notifyLoadingState(_ isLoading: Bool)
        case updateCommentList([Comment])
        case handleError(_ error: CommentViewError)
    }
    
    struct State {
        @Pulse var commentList: [Comment] = []
        @Pulse var isLoading: Bool = false
        @Pulse var error: CommentViewError?
    }
    
    var initialState: State = State()
    
    private let fetchCommentListUseCase: FetchCommentList
    
    init(postId: Int,
         fetchCommentListUseCase: FetchCommentList) {
        self.fetchCommentListUseCase = fetchCommentListUseCase
        action.onNext(.loadCommentList(postId: postId))
        logLifeCycle()
    }
    
    deinit {
        logLifeCycle()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .loadCommentList(postId):
            return self.fetchCommentList(postId: postId)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case .notifyLoadingState(let isLoad):
            newState.isLoading = isLoad
        case let .updateCommentList(list):
            newState.commentList = list
        case let .handleError(error):
            newState.error = error
        }
        
        return newState
    }
}

extension CommentListViewReactor {
    private func fetchCommentList(postId: Int) -> Observable<Mutation> {
        let loadingStart = Observable.just(Mutation.notifyLoadingState(true))
        
        let fetchCommentList = fetchCommentListUseCase.execute(postId: postId)
            .asObservable()
            .map { Mutation.updateCommentList($0) }
        
        let loadingStop = Observable.just(Mutation.notifyLoadingState(false))
        
        return .concat([loadingStart,
                        fetchCommentList,
                        loadingStop])
    }
}

