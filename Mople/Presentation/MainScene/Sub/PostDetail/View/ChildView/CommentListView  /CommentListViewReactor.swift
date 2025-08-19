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

enum CommentEdit {
    case add(comments: [Comment])
    case edit(comment: Comment)
    case delete(id: Int)
    case refresh(comments: [Comment])
}

enum CommentLoading {
    case new(Comment)
    case edit(id: Int)
    case replace(Comment)
}

final class CommentListViewReactor: Reactor, LifeCycleLoggable {
    
    enum Action {
        case fetchPage(postId: Int, isRefresh: Bool)
        case fetchNextPage
        case createComment(content: String, mentions: [Int])
        case editComment(id: Int, content: String, mentions: [Int])
        case likeComment(id: Int)
        case deleteComment(id: Int)
        case reportComment(id: Int)
        case showWriterImage(name: String?, imagePath: String?)
    }
    
    enum Mutation {
        case updateComment([Comment])
        case reportedComment
        case updateLoadingState(Bool)
        case catchError(Error)
    }
    
    struct State {
        @Pulse var comments: [Comment] = []
        @Pulse var reportedComment: Void?
        @Pulse var loadState: (isLoad: Bool, mode: LoadMode) = (false, .none)
        @Pulse var error: Error?
    }
    
    // MARK: - Variables
    var initialState: State = State()
//    var isLoading: Bool = false
    private var postId: Int?
    private var loadMode: LoadMode = .none
    private(set) var page: PageInfo?
    
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
            return fetchPage(postId: postId, isRefresh: true)
        case .fetchNextPage:
            return fetchNextPage()
        case let .createComment(content, mentions):
            return createComment(comment: content,
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
    
    private func updateLoadingMode(_ action: Action) {
        switch action {
        case let .fetchPage(_, isRefersh):
            loadMode = isRefersh ? .refresh : .more
        case .fetchNextPage:
            loadMode = .more
        default:
            loadMode = .none
        }
    }
    
    private func shouldAction(_ action: Action) -> Bool {
        let curruntLoading = currentState.loadState.isLoad
        
        switch action {
        case .showWriterImage:
            return true
        default:
            return curruntLoading == false
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case let .updateComment(comments):
            newState.comments = comments
        case .reportedComment:
            newState.reportedComment = ()
        case let .updateLoadingState(isLoad):
            newState.loadState = (isLoad, loadMode)
        case let .catchError(err):
            newState.error = err
        }
        return newState
    }
}

// MARK: - 댓글
extension CommentListViewReactor {
    
    // MARK: - 댓글 불러오기
    private func fetchPage(postId: Int,
                           cursor: String? = nil,
                           isRefresh: Bool = false) -> Observable<Mutation> {
        updatePostId(postId)
        let fetchPaeg = fetchCommentListUseCase.execute(postId: postId, nextCursor: cursor)
            .map { result in
                self.page = result.info
                let comments = result.content
                let editCase: CommentEdit = isRefresh ? .refresh(comments: comments) : .add(comments: comments)
                return self.updateCommentList(editCase: editCase)
            }
        return requestWithLoading(task: fetchPaeg, defferredLoadingDelay: .seconds(0))
    }
    
    private func updatePostId(_ postId: Int)  {
        guard self.postId == nil else { return }
        self.postId = postId
    }
    
    // MARK: - 댓글 더 불러오기
    private func fetchNextPage() -> Observable<Mutation> {
        guard let postId,
              let nextCursor = page?.nextCursor else { return .empty() }
        return fetchPage(postId: postId, cursor: nextCursor)
    }
    
    // MARK: - 댓글 리프레쉬
    private func resetPage() -> Observable<Mutation> {
        guard let postId else { return .empty() }
        self.page = nil
        return fetchPage(postId: postId, isRefresh: true)
    }
    
    // MARK: - 댓글 생성
    private func createComment(comment: String,
                               mentions: [Int] = []) -> Observable<Mutation> {
        guard let postId else { return .empty() }
        let mockComment = Comment.mockComment()
        let addMock = updateLoadingComment(loadingCase: .new(mockComment))
        
        let createComment = createCommentUseCase
            .execute(postId: postId,
                     comment: comment,
                     mentions: mentions)
            .delay(.seconds(1), scheduler: MainScheduler.instance)
            .map({
                var newComment = $0
                newComment.uuid = mockComment.uuid
                return newComment
            })
            .map { self.updateLoadingComment(loadingCase: .replace($0)) }
        
        return .just(addMock)
            .concat(createComment)
    }
    
    // MARK: - 댓글 편집
    private func editComment(id: Int,
                             text: String,
                             mentions: [Int] = []) -> Observable<Mutation> {
        let loadingComment = updateLoadingComment(loadingCase: .edit(id: id))
        let editComment = editCommentUseCase
            .execute(id: id,
                     text: text,
                     mentions: mentions)
            .delay(.seconds(1), scheduler: MainScheduler.instance)
            .map { self.updateCommentList(editCase: .edit(comment: $0)) }
        
        return .just(loadingComment)
            .concat(editComment)
    }

    // MARK: - 댓글 삭제
    private func deleteComment(id: Int) -> Observable<Mutation> {
        return deleteCommentUseCase
            .execute(commentId: id)
            .map { self.updateCommentList(editCase: .delete(id: id)) }
    }
    
    // MARK: - 댓글 좋아요
    private func likeComment(id: Int) -> Observable<Mutation> {
        return likeCommentUseCase
            .execute(commentId: id)
            .map { self.updateCommentList(editCase: .edit(comment: $0)) }
    }
    
    // MARK: - 댓글 신고
    private func reportComment(id: Int) -> Observable<Mutation> {
        return reportUseCase
            .execute(type: .comment(id: id), reason: nil)
            .map { Mutation.reportedComment }
    }
    
    // MARK: - 댓글 리스트 편집
    private func updateCommentList(editCase: CommentEdit) -> Mutation {
        var comments = currentState.comments
        switch editCase {
        case .add(let commentList):
            comments.append(contentsOf: commentList)
        case .edit(let comment):
            editComment(comments: &comments,
                        comment: comment)
        case .delete(let id):
            comments.removeAll { $0.id == id }
        case .refresh(let commentList):
            comments = commentList
        }
        return .updateComment(comments)
    }
    
    private func editComment(comments: inout [Comment], comment: Comment) {
        guard let editIndex = comments.firstIndex(where: { $0.id == comment.id }) else { return }
        comments[editIndex] = comment
    }
    
    // MARK: - 댓글 로딩
    private func updateLoadingComment(loadingCase: CommentLoading) -> Mutation {
        var comments = currentState.comments
        switch loadingCase {
        case .new(let comment):
            comments.insert(comment, at: 0)
        case .edit(let id):
            updateLoadingComment(comments: &comments, id: id)
        case .replace(let comment):
            replaceComment(comments: &comments,
                           replceComment: comment)
        }
        return .updateComment(comments)
    }
    
    private func updateLoadingComment(comments: inout [Comment], id: Int) {
        guard let loadingIndex = comments.firstIndex(where: { $0.id == id }) else { return }
        comments[loadingIndex].isLoading = true
    }
    
    private func replaceComment(comments: inout [Comment],
                                replceComment comment: Comment) {
        guard let replceIndex = comments.firstIndex(where: { $0.uuid == comment.uuid }) else { return }
        comments[replceIndex] = comment
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
