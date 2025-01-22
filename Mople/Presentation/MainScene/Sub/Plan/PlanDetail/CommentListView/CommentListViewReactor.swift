//
//  CommentListViewReactor.swift
//  Mople
//
//  Created by CatSlave on 1/16/25.
//
import Foundation
import ReactorKit

protocol CommentListCommands {
    func createComment(comment: String)
}

enum CommentViewError: Error {
    
}

final class CommentListViewReactor: Reactor, LifeCycleLoggable {
    
    enum Action {
        case loadCommentList(postId: Int)
        case createComment(comment: String)
    }
    
    enum Mutation {
        case updateCommentList([Comment])
    }
    
    struct State {
        @Pulse var commentList: [Comment] = []
    }
    
    var initialState: State = State()
    
    private let fetchCommentListUseCase: FetchCommentList
    private let createCommentUseCase: CreateComment
    private let deleteCommentUseCase: DeleteComment
    private let editCommentUseCase: EditComment
    private let delegate: CommentListDelegate
    private let postId: Int
    
    init(postId: Int,
         fetchCommentListUseCase: FetchCommentList,
         createCommentUseCase: CreateComment,
         deleteCommentUseCase: DeleteComment,
         editCommentUseCase: EditComment,
         delegate: CommentListDelegate) {
        self.postId = postId
        self.fetchCommentListUseCase = fetchCommentListUseCase
        self.createCommentUseCase = createCommentUseCase
        self.deleteCommentUseCase = deleteCommentUseCase
        self.editCommentUseCase = editCommentUseCase
        self.delegate = delegate
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
        case let .createComment(comment):
            return self.createComment(comment: comment)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case let .updateCommentList(list):
            newState.commentList = list.sorted(by: <)
        }
        return newState
    }
}

extension CommentListViewReactor {
    
    private func fetchCommentList(postId: Int) -> Observable<Mutation> {
        
        let loadingStart = self.setLoading(true)
        
        let fetchCommentList = fetchCommentListUseCase.execute(postId: postId)
            .asObservable()
            .map { Mutation.updateCommentList($0) }
        
        let loadingStop = setLoading(false)
        
        return .concat([loadingStart,
                        fetchCommentList,
                        loadingStop])
    }
    
    private func createComment(comment: String) -> Observable<Mutation> {
        
        let createComment = createCommentUseCase
            .execute(postId: postId,
                     comment: comment)
            .asObservable()
            .map { Mutation.updateCommentList($0) }
        
        return withDeferredLoading(
            task: createComment,
            complation: { [weak self] in
                self?.delegate.createdComment()
            })
    }
}

// MARK: - To Parents
extension CommentListViewReactor {
    
    /// 작업 완료 후 일정시간 뒤 로딩종료
    private func withDeferredLoading(task: Observable<Mutation>,
                                     complation: (() -> Void)? = nil,
                                     delay: Int = 1) -> Observable<Mutation> {
        let loadingStart = self.setLoading(true)
        
        let loadingStop = Observable.just(())
            .delay(.seconds(delay), scheduler: MainScheduler.instance)
            .do(onNext: { [weak self] _ in
                self?.delegate.commentListLoading(false)
                complation?()
            })
            .flatMap { Observable<Mutation>.empty() }
        
        return .concat([loadingStart,
                        task,
                        loadingStop])
    }
    
    /// 상위 뷰에게 로딩이 끝났음을 전달
    private func setLoading(_ isLoading: Bool,
                            delay: Int = 0) -> Observable<Mutation>{
        return Observable.just(())
            .delay(.seconds(delay), scheduler: MainScheduler.instance)
            .do(onNext: { [weak self] in
                self?.delegate.commentListLoading(isLoading)
            })
            .flatMap { Observable<Mutation>.empty() }
    }
}

extension CommentListViewReactor: CommentListCommands {
    func createComment(comment: String) {
        self.action.onNext(.createComment(comment: comment))
    }
}
