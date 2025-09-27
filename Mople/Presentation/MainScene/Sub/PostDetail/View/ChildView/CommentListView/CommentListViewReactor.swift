//
//  CommentListViewReactor.swift
//  Mople
//
//  Created by CatSlave on 1/16/25.
//
import UIKit
import ReactorKit

enum LoadMode {
    case more
    case edit
    case refresh
}

final class CommentListViewReactor: Reactor, LifeCycleLoggable {
    
    enum Action {
        case fetchComment(postId: Int, isRefresh: Bool)
        case createComment(parentId: Int?, content: String, mentions: [Int])
        case editComment(comment: Comment, content: String, mentions: [Int])
        case deleteComment(Comment)
        case reportComment(Comment)
        case moreComment
        case showWriterImage(Comment)
    }
    
    enum Mutation {
        case fetchedComment([Comment])
        case fetchedPage(PageInfo?)
        case writedComment
        case editedComment
        case reportedComment
        case updateLoadingState(Bool)
        case catchError(Error)
    }
    
    struct State {
        @Pulse var comments: [Comment] = []
        @Pulse var pageInfo: PageInfo?
        @Pulse var addedComment: Void?
        @Pulse var editedComment: Void?
        @Pulse var reportedComment: Void?
        @Pulse var isUiLoading: (isLoad: Bool, mode: LoadMode)?
        @Pulse var error: Error?
    }
    
    // MARK: - Variables
    var initialState: State = State()
    private var postId: Int?
    private var lastCurosr: String?
    private var loadingMode: LoadMode = .more
    private var isApiLoading: Bool = false
    
    // MARK: - UseCase
    private let fetchCommentListUseCase: FetchCommentList
    private let createCommentUseCase: CreateComment
    private let deleteCommentUseCase: DeleteComment
    private let editCommentUseCase: EditComment
    private let reportUseCase: ReportPost
    
    // MARK: - Coordinator
    private weak var coordinator: CommentListCoordination?
    
    // MARK: - LifeCycle
    init(fetchCommentListUseCase: FetchCommentList,
         createCommentUseCase: CreateComment,
         deleteCommentUseCase: DeleteComment,
         editCommentUseCase: EditComment,
         reportUseCase: ReportPost,
         coordinator: CommentListCoordination) {
        self.fetchCommentListUseCase = fetchCommentListUseCase
        self.createCommentUseCase = createCommentUseCase
        self.deleteCommentUseCase = deleteCommentUseCase
        self.editCommentUseCase = editCommentUseCase
        self.reportUseCase = reportUseCase
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
        case let .fetchComment(postId, _):
            return fetchCommentWithLoading(postId: postId)
        case .moreComment:
            return moreComment()
        case let .createComment(parentId, content, mentions):
            return createComment(comment: content,
                                 mentions: mentions)
        case let .editComment(comment, text, mentions):
            return editComment(comment: comment,
                               text: text,
                               mentions: mentions)
        case let .deleteComment(comment):
            return deleteComment(comment: comment)
        case let .reportComment(comment):
            return reportComment(comment: comment)
        case let .showWriterImage(comment):
            return showWritterImage(comment: comment)
        }
    }
    
    private func shouldAction(_ action: Action) -> Bool {
        switch action {
        case .reportComment, .showWriterImage:
            return true
        default:
            guard !isApiLoading else { return false }
            isApiLoading = true
            return true
        }
    }
    
    private func updateLoadingMode(_ action: Action) {
        switch action {
        case .createComment, .editComment, .deleteComment:
            loadingMode = .edit
        case let .fetchComment(_ , isRefersh):
            loadingMode = isRefersh ? .refresh : .more
        case .moreComment:
            loadingMode = .more
        default: break
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case let .fetchedComment(models):
            newState.comments = models
        case let .fetchedPage(pageInfo):
            newState.pageInfo = pageInfo
        case .writedComment:
            newState.addedComment = ()
        case .editedComment:
            newState.editedComment = ()
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

// MARK: - Show Comment Writer Image
extension CommentListViewReactor {
    private func showWritterImage(comment: Comment) -> Observable<Mutation> {
        guard let writerName = comment.writerName,
              let writerThumbnailPath = comment.writerThumbnailPath else { return .empty() }
        
        coordinator?.presentWriterImageView(title: writerName,
                                            imagePath: writerThumbnailPath,
                                            defaultType: .user)
        
        return .empty()
    }
}

// MARK: - Data Request
extension CommentListViewReactor {
    
    // MARK: - 댓글 불러오기
    private func fetchComment(postId: Int,
                              cursor: String? = nil) -> Observable<Mutation> {
        return fetchCommentListUseCase.execute(postId: postId, nextCursor: cursor)
            .flatMap({ [weak self] commentPage -> Observable<Mutation> in
                guard let self else { return .empty() }
                let addSection = addComment(commentPage.content, isFirst: cursor == nil)
                let page = Mutation.fetchedPage(commentPage.page)
                return .of(addSection, page)
            })
            .do(onDispose: { [weak self] in
                self?.lastCurosr = cursor
            })
    }
    
    private func fetchCommentWithLoading(postId: Int) -> Observable<Mutation> {
        updatePostId(postId)
        let fetch = fetchComment(postId: postId)
        return requestWithLoading(task: fetch, defferredLoadingDelay: .seconds(0))
    }
    
    private func moreComment() -> Observable<Mutation> {
        guard let postId,
              let cursor = currentState.pageInfo?.nextCursor,
              lastCurosr != cursor else { return .empty() }
        
        let fetch = fetchComment(postId: postId, cursor: cursor)
        
        return requestWithLoading(task: fetch)
    }
    
    private func updatePostId(_ postId: Int)  {
        guard self.postId == nil else { return }
        self.postId = postId
    }
    
    // MARK: - 댓글 생성
    private func createComment(comment: String,
                               mentions: [Int] = []) -> Observable<Mutation> {
        guard let postId else { return .empty() }
        
        let createComment = createCommentUseCase
            .execute(postId: postId,
                     comment: comment,
                     mentions: mentions)
            .compactMap({ self.addCommentItem($0) })
        
        return requestWithLoading(task: createComment)
            .concat(Observable.just(.writedComment))
    }
    
    // MARK: - 댓글 편집
    private func editComment(comment: Comment,
                             text: String,
                             mentions: [Int] = []) -> Observable<Mutation> {
        guard let id = comment.id else { return .empty() }
        
        let editComment = editCommentUseCase
            .execute(id: id,
                     text: text,
                     mentions: mentions)
            .compactMap({ self.editCommentItem($0) })
        
        return requestWithLoading(task: editComment)
            .concat(Observable.just(.editedComment))
    }

    // MARK: - 댓글 삭제
    private func deleteComment(comment: Comment) -> Observable<Mutation> {
        guard let selectedCommentId = comment.id else { return .empty() }
        
        let deleteComment = deleteCommentUseCase
            .execute(commentId: selectedCommentId)
            .compactMap({ self.deleteCommentItem(selectedCommentId) })
        
        return requestWithLoading(task: deleteComment)
            .concat(Observable.just(.editedComment))
    }
    
    // MARK: - 댓글 신고
    private func reportComment(comment: Comment) -> Observable<Mutation> {
        guard let id = comment.id else { return .empty() }
        
        return reportUseCase
            .execute(type: .comment(id: id), reason: nil)
            .map { Mutation.reportedComment }
    }
}

// MARK: - Section bulider
extension CommentListViewReactor {
    // MARK: - Comment List
    private func addComment(_ newComments: [Comment],
                            isFirst: Bool = false) -> Mutation {
        if isFirst {
            return .fetchedComment(newComments)
        } else {
            var comment = currentState.comments
            comment.append(contentsOf: newComments)
            return .fetchedComment(comment)
        }
    }
    
    // MARK: - Comment
    private func addCommentItem(_ newComment: Comment) -> Mutation? {
        var comments = currentState.comments
        comments.insert(newComment, at: 0)
        return .fetchedComment(comments)
    }
    
    private func editCommentItem(_ editComment: Comment) -> Mutation? {
        var comments = currentState.comments
        guard let commentId = editComment.id,
              let editCommentIndex = findCommentIndex(commentId: commentId) else { return nil }
        comments[editCommentIndex] = editComment
        return .fetchedComment(comments)
    }
    
    private func deleteCommentItem(_ commentId: Int) -> Mutation? {
        var comments = currentState.comments
        guard let deleteCommentIndex = findCommentIndex(commentId: commentId) else { return nil }
        comments.remove(at: deleteCommentIndex)
        return .fetchedComment(comments)
    }
    
    private func findCommentIndex(commentId: Int) -> Int? {
        return currentState.comments.firstIndex { $0.id == commentId }
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
