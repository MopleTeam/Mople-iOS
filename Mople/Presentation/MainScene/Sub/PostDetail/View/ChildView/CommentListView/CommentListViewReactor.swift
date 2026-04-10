//
//  CommentListViewReactor.swift
//  Mople
//
//  Created by CatSlave on 1/16/25.
//
import UIKit
import ReactorKit

enum CommentListType {
    case parent
    case child(parent: Comment, meetId: Int)
}

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
        case deletedComment(id: Int)
        case reportComment(id: Int)
        case showWriterImage(name: String?, imagePath: String?)
        case showReply(parentComment: Comment, meetId: Int)
        case endFlow
    }
    
    enum Mutation {
        case updateComment([Comment])
        case adjustCommentCount(increment: Bool)
        case reportedComment
        case updateLoadingState(Bool)
        case catchError(Error)
    }

    struct State {
        @Pulse var comments: [Comment] = []
        @Pulse var adjustCommentCount: Bool?
        @Pulse var reportedComment: Void?
        @Pulse var loadState: (isLoad: Bool, mode: LoadMode) = (false, .none)
        @Pulse var error: Error?
    }
    
    // MARK: - Variables
    let type: CommentListType
    var initialState: State = State()
    var isLoading: Bool = false
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
    init(type: CommentListType,
         fetchCommentListUseCase: FetchCommentList,
         fetchReplyCommentListUseCase: FetchReplyCommentList,
         createCommentUseCase: CreateComment,
         createReplyUseCase: CreateReplyComment,
         deleteCommentUseCase: DeleteComment,
         editCommentUseCase: EditComment,
         reportUseCase: ReportPost,
         likeCommentUseCase: LikeComment,
         coordinator: CommentListCoordination) {
        self.type = type
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
        initialAction()
    }
    
    deinit {
        logLifeCycle()
    }
    
    private func initialAction() {
        if case .child(let parentComment, _) = type,
           let parentPostId = parentComment.postId {
            action.onNext(.fetchPage(postId: parentPostId, isRefresh: true))
        }
    }
    
    // MARK: - State Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        guard shouldAction(action) else { return .empty() }
        updateLoadingMode(action)
        
        switch action {
        case let .fetchPage(postId, _):
            return handleFetch(postId: postId)
        case let .createComment(content, mentions):
            return handleCreateComment(text: content,
                                       mentions: mentions)
        case .fetchNextPage:
            return fetchNextPage()
        case let .editComment(id, text, mentions):
            return editComment(id: id,
                               text: text,
                               mentions: mentions)
        case let .deleteComment(id):
            return deleteComment(id: id)
        case let .deletedComment(id):
            return deletedComment(id: id)
        case let .reportComment(id):
            return reportComment(id: id)
        case let .likeComment(id):
            return likeComment(id: id)
        case let .showWriterImage(name, imagePath):
            return showWritterImage(name: name, imagePath: imagePath)
        case let .showReply(parentComment, meetId):
            return showReply(parentComment: parentComment, meetId: meetId)
        case .endFlow:
            return popView()
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
        switch action {
        case .showWriterImage, .showReply:
            return true
        default:
            return !isLoading
        }
    }
    
    private func handleFetch(postId: Int) -> Observable<Mutation> {
        switch type {
        case .parent:
            return fetchPage(postId: postId, isRefresh: true)
        case let .child(parent, _):
            return fetchReplyPage(postId: postId,
                                  parentComment: parent,
                                  isRefresh: true)
        }
    }
    
    private func handleCreateComment(text: String, mentions: [Int]) -> Observable<Mutation> {
        switch type {
        case .parent:
            return createComment(comment: text,
                                 mentions: mentions)
        case let .child(parent, _):
            guard let id = parent.id else { return .empty() }
            return createReply(parentId: id, comment: text, mentions: mentions)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case let .updateComment(comments):
            newState.comments = comments
        case let .adjustCommentCount(increment):
            newState.adjustCommentCount = increment
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
    
    // MARK: - 댓글
    private func fetchPage(postId: Int,
                           cursor: String? = nil,
                           isRefresh: Bool = false) -> Observable<Mutation> {
        self.postId = postId
        let fetchPaeg = fetchCommentListUseCase.execute(postId: postId, nextCursor: cursor)
            .map { result in
                self.page = result.info
                let comments = result.content
                let editCase: CommentEdit = isRefresh ? .refresh(comments: comments) : .add(comments: comments)
                return self.updateCommentList(editCase: editCase)
            }
        return requestWithLoading(task: fetchPaeg, defferredLoadingDelay: .seconds(0))
    }
    
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
            .flatMap { replaceMutation -> Observable<Mutation> in
                return .of(.adjustCommentCount(increment: true), replaceMutation)
            }

        return .just(addMock)
            .concat(createComment)
    }

    // MARK: - 대댓글
    private func fetchReplyPage(postId: Int,
                                parentComment: Comment,
                                cursor: String? = nil,
                                isRefresh: Bool = false) -> Observable<Mutation> {
        guard let commentId = parentComment.id else { return .empty() }
        self.postId = postId
        let fetchReply = fetchReplyCommentListUseCase.execute(postId: postId,
                                                              commentId: commentId,
                                                              nextCursor: cursor)
            .map { result in
                self.page = result.info
                var comments = result.content
                if isRefresh {
                    comments.insert(parentComment, at: 0)
                }
                let editCase: CommentEdit = isRefresh ? .refresh(comments: comments) : .add(comments: comments)
                return self.updateCommentList(editCase: editCase)
            }
        
        return requestWithLoading(task: fetchReply, defferredLoadingDelay: .seconds(0))
    }
   
    private func createReply(parentId: Int,
                             comment: String,
                             mentions: [Int] = []) -> Observable<Mutation> {
        guard let postId else { return .empty() }
        
        let mockComment = Comment.mockComment()
        let addMock = updateLoadingComment(loadingCase: .new(mockComment))
        
        let createComment = createReplyUseCase
            .execute(postId: postId,
                     parentId: parentId,
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
    
    // MARK: - 페이징
    private func fetchNextPage() -> Observable<Mutation> {
        guard let postId,
              let nextCursor = page?.nextCursor else { return .empty() }
        
        switch type {
        case .parent:
            return fetchPage(postId: postId, cursor: nextCursor)
        case let .child(parent, _):
            return fetchReplyPage(postId: postId,
                                  parentComment: parent,
                                  cursor: nextCursor)
        }
    }
    
    // MARK: - 리프레쉬
    private func resetPage() -> Observable<Mutation> {
        guard let postId else { return .empty() }
        self.page = nil
        
        switch type {
        case .parent:
            return fetchPage(postId: postId, isRefresh: true)
        case let .child(parent, _):
            return fetchReplyPage(postId: postId,
                                  parentComment: parent,
                                  isRefresh: true)
        }
    }
}


// MARK: - 댓글 공통
extension CommentListViewReactor {
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
        let task = deleteCommentUseCase
            .execute(commentId: id)
            .observe(on: MainScheduler.instance)
            .flatMap { _ -> Observable<Mutation> in
                let deleteUpdate = self.updateCommentList(editCase: .delete(id: id))
                return .of(.adjustCommentCount(increment: false), deleteUpdate)
            }
        return requestWithLoading(task: task)
    }

    private func deletedComment(id: Int) -> Observable<Mutation> {
        let updateComment = self.updateCommentList(editCase: .delete(id: id))
        return .of(.adjustCommentCount(increment: false), updateComment)
    }
    
    // MARK: - 댓글 좋아요
    private func likeComment(id: Int) -> Observable<Mutation> {
        let task = likeCommentUseCase
            .execute(commentId: id)
            .map { self.updateCommentList(editCase: .edit(comment: $0)) }
        return requestWithLoading(task: task)
    }
    
    // MARK: - 댓글 신고
    private func reportComment(id: Int) -> Observable<Mutation> {
        let task = reportUseCase
            .execute(type: .comment(id: id), reason: nil)
            .map { Mutation.reportedComment }
        return requestWithLoading(task: task)
    }
    
    // MARK: - 댓글 리스트 편집
    private func updateCommentList(editCase: CommentEdit) -> Mutation {
        var comments = currentState.comments
        switch editCase {
        case .add(let commentList):
            setAddCommnetCommentList(comments: commentList, list: &comments)
        case .edit(let comment):
            editComment(comments: &comments,
                        comment: comment)
        case .delete(let id):
            handleDeleteComment(comments: &comments, id: id)
        case .refresh(let commentList):
            setFirstCommentList(comments: commentList,
                                list: &comments)
        }
        return .updateComment(comments)
    }
    
    private func setAddCommnetCommentList(comments: [Comment], list: inout [Comment]) {
        list.append(contentsOf: comments)
        if case .child = type {
            // id 기준으로 중복제거 (Set<Int> 사용)
            var seen = Set<Int>()
            list = list.filter { comment in
                guard let id = comment.id else { return true }
                return seen.insert(id).inserted  // insert가 성공하면 true, 이미 있으면 false
            }
            
            list.sort {
                // parent 타입이 무조건 앞에
                if $0.type == .parent && $1.type == .child {
                    return true
                }
                if $0.type == .child && $1.type == .parent {
                    return false
                }
                
                // 같은 타입끼리는 날짜순 정렬
                guard let date1 = $0.createdDate,
                      let date2 = $1.createdDate else { return true }
                return date1 < date2
            }
        }
    }
    
    private func setFirstCommentList(comments: [Comment], list: inout [Comment]) {
        switch type {
        case .parent:
            list = comments
        case .child:
            list.removeAll { $0.type == .child }
            list.append(contentsOf: comments)
        }
    }
    
    private func editComment(comments: inout [Comment], comment: Comment) {
        guard let editIndex = comments.firstIndex(where: { $0.id == comment.id }) else { return }
        comments[editIndex] = comment
    }
    
    private func handleDeleteComment(comments: inout [Comment], id: Int) {
        if case .child(let parent, _) = type, parent.id == id {
            coordinator?.deleteParentComment(id: id)
        } else {
            comments.removeAll { $0.id == id }
        }
    }
}

// MARK: - 댓글 로딩
extension CommentListViewReactor {
    private func updateLoadingComment(loadingCase: CommentLoading) -> Mutation {
        var comments = currentState.comments
        switch loadingCase {
        case .new(let comment):
            addLoadingComment(comment, list: &comments)
        case .edit(let id):
            updateLoadingComment(comments: &comments, id: id)
        case .replace(let comment):
            replaceComment(comments: &comments,
                           replceComment: comment)
        }
        return .updateComment(comments)
    }
    
    private func addLoadingComment(_ comment: Comment, list: inout [Comment]) {
        switch type {
        case .parent:
            list.insert(comment, at: 0)
        case .child:
            list.append(comment)
        }
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
        coordinator?.presentWriterImageView(title: name,
                                            imagePath: imagePath,
                                            defaultType: .user)
        
        return .empty()
    }
    
    private func showReply(parentComment: Comment, meetId: Int) -> Observable<Mutation> {
        coordinator?.pushReplyPage(parentComment: parentComment, meetId: meetId)
        return .empty()
    }
    
    private func popView() -> Observable<Mutation> {
        coordinator?.pop()
        return .empty()
    }
}

// MARK: - Loading & Error
extension CommentListViewReactor: LoadingReactor {
    func updateLoadingState(isLoad: Bool) {
        isLoading = isLoad
    }
    
    func updateLoadingMutation(_ isLoading: Bool) -> Mutation {
        return .updateLoadingState(isLoading)
    }
    
    func catchErrorMutation(_ error: Error) -> Mutation {
        return .catchError(error)
    }
}
