//
//  CommentListViewReactor.swift
//  Mople
//
//  Created by CatSlave on 1/16/25.
//
import UIKit
import ReactorKit

enum LoadMode {
    case edit
    case refresh
    case more
    case none
}

final class CommentListViewReactor: Reactor, LifeCycleLoggable {
    
    enum Action {
        case fetchPage(postId: Int, isRefresh: Bool)
        case fetchNextPage(nextCursor: String)
        case fetchReplyComment(parentId: Int, cursor: String?)
        case createComment(content: String, mentions: [Int])
        case createReply(parentId: Int, content: String, mentions: [Int])
        case editComment(id: Int, content: String, mentions: [Int])
        case likeComment(id: Int)
        case deleteComment(id: Int)
        case reportComment(id: Int)
        case cachingReply(parentId: Int, replyPage: CommentPage)
        case showWriterImage(name: String?, imagePath: String?)
    }
    
    enum Mutation {
        case fetchedPage(CommentPage)
        case fetchedReplyComment(parentId: Int, page: CommentPage)
        case addedComment(Comment)
        case editedComment(Comment)
        case deleteComment(id: Int)
        case reportedComment
        case updateLoadingState(Bool)
        case catchError(Error)
    }
    
    struct State {
        @Pulse var fetchedPage: CommentPage?
        @Pulse var fetchedReplyComment: (parentId: Int, page: CommentPage)?
        @Pulse var addedComment: Comment?
        @Pulse var editedComment: Comment?
        @Pulse var deletedCommentId: Int?
        @Pulse var reportedComment: Void?
        @Pulse var isUiLoading: (isLoad: Bool, mode: LoadMode)?
        @Pulse var error: Error?
    }
    
    // MARK: - Variables
    var initialState: State = State()
    private var postId: Int?
    private var loadingMode: LoadMode = .none
    private var isApiLoading: Bool = false
    private var cachedReply: [Int: CommentPage] = .init()
    
    // MARK: - UseCase - Parent
    private let fetchCommentListUseCase: FetchCommentList
    private let createCommentUseCase: CreateComment
    private let deleteCommentUseCase: DeleteComment
    private let editCommentUseCase: EditComment
    private let reportUseCase: ReportPost
    private let likeCommentUseCase: LikeComment
    
    // MARK: - UseCase - Child
    private let fetchReplyCommentListUseCase: FetchReplyCommentList
    private let createReplyUseCase: CreateReplyComment
    
    // MARK: - Coordinator
    private weak var coordinator: CommentListCoordination?
    
    // MARK: - LifeCycle
    init(fetchCommentListUseCase: FetchCommentList,
         fetchReplyCommentListUseCase: FetchReplyCommentList,
         createCommentUseCase: CreateComment,
         createReplyUseCase: CreateReplyComment,
         deleteCommentUseCase: DeleteComment,
         editCommentUseCase: EditComment,
         reportUseCase: ReportPost,
         likeCommentUseCase: LikeComment,
         coordinator: CommentListCoordination) {
        self.fetchCommentListUseCase = fetchCommentListUseCase
        self.fetchReplyCommentListUseCase = fetchReplyCommentListUseCase
        self.createCommentUseCase = createCommentUseCase
        self.createReplyUseCase = createReplyUseCase
        self.deleteCommentUseCase = deleteCommentUseCase
        self.editCommentUseCase = editCommentUseCase
        self.reportUseCase = reportUseCase
        self.likeCommentUseCase = likeCommentUseCase
        self.coordinator = coordinator
        logLifeCycle()
    }
    
    deinit {
        logLifeCycle()
    }
    
    // MARK: - State Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        guard shouldAction(action) else { return .empty() }
        updateLoadingMode(action)
        
        switch action {
        case let .fetchPage(postId, _):
            return fetchPage(postId: postId)
        case let .fetchNextPage(cursor):
            return fetchNextPage(cursor: cursor)
        case let .fetchReplyComment(parentId, cursor):
            return loadReplyComment(parentId: parentId, cursor: cursor)
        case let .cachingReply(parentId, page):
            return cachedReplyPage(parentId: parentId, replyPage: page)
        case let .createComment(content, mentions):
            return createComment(comment: content,
                                 mentions: mentions)
        case let .createReply(parentId, content, mentions):
            return createReply(parentId: parentId,
                               comment: content,
                               mentions: mentions)
        case let .editComment(id, text, mentions):
            return editComment(id: id,
                               text: text,
                               mentions: mentions)
        case let .deleteComment(id):
            return deleteComment(id: id)
        case let .reportComment(id):
            return reportComment(id: id)
        case let .likeComment(id):
            return likeComment(id: id)
        case let .showWriterImage(name, imagePath):
            return showWritterImage(name: name, imagePath: imagePath)
        }
    }
    
    private func shouldAction(_ action: Action) -> Bool {
        switch action {
        case .reportComment, .showWriterImage, .cachingReply:
            return true
        default:
            guard !isApiLoading else { return false }
            return true
        }
    }
    
    private func updateLoadingMode(_ action: Action) {
        switch action {
        case .createComment, .editComment, .deleteComment, .likeComment:
            loadingMode = .edit
        case let .fetchPage(_, isRefersh):
            loadingMode = isRefersh ? .refresh : .more
        case .fetchNextPage:
            loadingMode = .more
        default:
            loadingMode = .none
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case let .fetchedPage(page):
            newState.fetchedPage = page
        case let .fetchedReplyComment(parentId, page):
            newState.fetchedReplyComment = (parentId, page)
        case let .addedComment(comment):
            newState.addedComment = (comment)
        case let .editedComment(Comment):
            newState.editedComment = Comment
        case let .deleteComment(id):
            newState.deletedCommentId = id
        case .reportedComment:
            newState.reportedComment = ()
        case let .updateLoadingState(isUiLoad):
            newState.isUiLoading = (isUiLoad, loadingMode)
            if !isUiLoad {
                isApiLoading = false
            }
        case let .catchError(err):
            newState.error = err
        }
        return newState
    }
}

// MARK: - 댓글
extension CommentListViewReactor {
    
    // MARK: - 댓글 불러오기
    private func fetchPage(postId: Int) -> Observable<Mutation> {
        isApiLoading = true
        updatePostId(postId)
        let fetchPaeg = fetchCommentListUseCase.execute(postId: postId, nextCursor: nil)
            .map { Mutation.fetchedPage($0) }
        return requestWithLoading(task: fetchPaeg, defferredLoadingDelay: .seconds(0))
            .do(onNext: { [weak self] _ in
                self?.cachedReply.removeAll()
            })
    }
    
    private func fetchNextPage(cursor: String) -> Observable<Mutation> {
        isApiLoading = true
        guard let postId else { return .empty()}
        let fetchNextPage = fetchCommentListUseCase
            .execute(postId: postId,
                     nextCursor: cursor)
            .delay(.milliseconds(500), scheduler: MainScheduler.instance)
            .map { Mutation.fetchedPage($0) }
        
        return requestWithLoading(task: fetchNextPage, defferredLoadingDelay: .seconds(0))
    }
    
    private func updatePostId(_ postId: Int)  {
        guard self.postId == nil else { return }
        self.postId = postId
    }
    
    // MARK: - 댓글 생성
    private func createComment(comment: String,
                               mentions: [Int] = []) -> Observable<Mutation> {
        guard let postId else { return .empty() }
        isApiLoading = true
        let createComment = createCommentUseCase
            .execute(postId: postId,
                     comment: comment,
                     mentions: mentions)
            .map { Mutation.addedComment($0) }
        
        return requestWithLoading(task: createComment)
    }
}

// MARK: - 대댓글
extension CommentListViewReactor {
    // MARK: - 대댓글 불러오기
    private func loadReplyComment(parentId: Int, cursor: String?) -> Observable<Mutation> {
        if let restoreReplyPage = restoreCachedReplyComment(parentId: parentId) {
            return .just(.fetchedReplyComment(parentId: parentId, page: restoreReplyPage))
        } else {
            return fetchReplyComment(parentId: parentId, cursor: cursor)
        }
    }
    
    private func fetchReplyComment(parentId: Int, cursor: String?) -> Observable<Mutation> {
        guard let postId else { return .empty() }
        return fetchReplyCommentListUseCase
            .execute(postId: postId,
                     commentId: parentId,
                     nextCursor: cursor)
            .map { Mutation.fetchedReplyComment(parentId: parentId, page: $0) }
    }

    // MARK: - 대댓글 생성
    private func createReply(parentId: Int,
                             comment: String,
                             mentions: [Int] = []) -> Observable<Mutation> {
        guard let postId else { return .empty() }
        isApiLoading = true
        let createReply = createReplyUseCase
            .execute(postId: postId,
                     parentId: parentId,
                     comment: comment,
                     mentions: mentions)
            .map { Mutation.addedComment($0) }
        
        return requestWithLoading(task: createReply)
    }
    
    // MARK: - 대댓글 캐쉬 데이터 저장
    private func cachedReplyPage(parentId: Int, replyPage: CommentPage) -> Observable<Mutation> {
        cachedReply[parentId] = replyPage
        return .empty()
    }
    
    private func restoreCachedReplyComment(parentId: Int) -> CommentPage? {
        guard let cachedReplyPage = cachedReply[parentId] else { return nil }
        cachedReply.removeValue(forKey: parentId)
        return cachedReplyPage
    }
}

// MARK: - 댓글 공통
extension CommentListViewReactor {
    // MARK: - 댓글 편집
    private func editComment(id: Int,
                             text: String,
                             mentions: [Int] = []) -> Observable<Mutation> {
        isApiLoading = true
        let editComment = editCommentUseCase
            .execute(id: id,
                     text: text,
                     mentions: mentions)
            .map { Mutation.editedComment($0) }
        
        return requestWithLoading(task: editComment)
    }

    // MARK: - 댓글 삭제
    private func deleteComment(id: Int) -> Observable<Mutation> {
        isApiLoading = true
        let deleteComment = deleteCommentUseCase
            .execute(commentId: id)
            .map { Mutation.deleteComment(id: id) }
        
        return requestWithLoading(task: deleteComment)
    }
    
    // MARK: - 댓글 좋아요
    private func likeComment(id: Int) -> Observable<Mutation> {
        isApiLoading = true
        let likeComment = likeCommentUseCase
            .execute(commentId: id)
            .map { Mutation.editedComment($0) }
        return requestWithLoading(task: likeComment)
    }
    
    // MARK: - 댓글 신고
    private func reportComment(id: Int) -> Observable<Mutation> {
        return reportUseCase
            .execute(type: .comment(id: id), reason: nil)
            .map { Mutation.reportedComment }
    }
}

// MARK: - Flow
extension CommentListViewReactor {
    private func showWritterImage(name: String?, imagePath: String?) -> Observable<Mutation> {
        //        coordinator?.presentWriterImageView(title: name,
        //                                            imagePath: [],
        //                                            defaultType: .user)
        
        return .empty()
    }
}

// MARK: - Loading & Error
extension CommentListViewReactor: LoadingReactor {
    func updateLoadingMutation(_ isLoading: Bool) -> Mutation {
        return .updateLoadingState(isLoading)
    }
    
    func catchErrorMutation(_ error: Error) -> Mutation {
        return .catchError(error)
    }
}
