//
//  CommentListViewReactor.swift
//  Mople
//
//  Created by CatSlave on 1/16/25.
//
import UIKit
import Domain
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
    case create(comments: [Comment])
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
        case refresh
        case createComment(content: String, mentions: [Int])
        case editComment(id: Int, content: String, mentions: [Int])
        case likeComment(id: Int)
        case deleteComment(id: Int)
        case deletedComment(id: Int)
        case reportComment(id: Int)
        // 답글 페이지에서 답글 생성/삭제 시, 메인 댓글 페이지의 해당 부모 댓글 '답글 N개'를 갱신하기 위한 액션
        case updateReplyCount(parentId: Int, increment: Bool)
        // 답글 페이지에서 부모 댓글의 좋아요 등 변경을 메인 댓글 페이지에 반영하기 위한 액션
        case updateParentComment(Comment)
        case showWriterImage(name: String?, imagePath: String?)
        case showReply(parentComment: Comment, meetId: Int)
        case endFlow
    }
    
    enum Mutation {
        case updateComment([Comment])
        case adjustCommentCount(increment: Bool)
        // 부모 댓글 목록 API의 totalCount(=부모 댓글 수)로 메인 카운트를 갱신
        case setCommentCount(Int)
        case reportedComment
        case updateLoadingState(Bool)
        case catchError(Error)
    }

    struct State {
        @Pulse var comments: [Comment] = []
        @Pulse var adjustCommentCount: Bool?
        @Pulse var commentCount: Int?
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
        case .refresh:
            return resetPage()
        case let .updateReplyCount(parentId, increment):
            return .just(updateParentReplyCount(parentId: parentId, increment: increment))
        case let .updateParentComment(comment):
            let updated = currentState.comments.map { $0.id == comment.id ? comment : $0 }
            return .just(.updateComment(updated))
        case let .editComment(id, text, mentions):
            guard let comment = currentState.comments.first(where: { $0.id == id }) else { return .empty() }
            return editComment(comment: comment,
                               text: text,
                               mentions: mentions)
        case let .deleteComment(id):
            guard let comment = currentState.comments.first(where: { $0.id == id }) else { return .empty() }
            return deleteComment(comment: comment)
        case let .deletedComment(id):
            let updated = currentState.comments.filter { $0.id != id }
            return .just(.updateComment(updated))
        case let .reportComment(id):
            guard let comment = currentState.comments.first(where: { $0.id == id }) else { return .empty() }
            return reportComment(comment: comment)
        case let .likeComment(id):
            guard let comment = currentState.comments.first(where: { $0.id == id }) else { return .empty() }
            return likeComment(comment: comment)
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
        case .refresh:
            loadMode = .refresh
        case .fetchNextPage:
            loadMode = .more
        default:
            loadMode = .none
        }
    }

    private func shouldAction(_ action: Action) -> Bool {
        switch action {
        case .showWriterImage, .showReply, .updateReplyCount, .updateParentComment:
            return true
        default:
            return !isLoading
        }
    }
    
    private func handleFetch(postId: Int) -> Observable<Mutation> {
        if self.postId == nil { self.postId = postId }
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
        case let .setCommentCount(count):
            newState.commentCount = count
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
    
    // MARK: - 부모 댓글 불러오기
    /// 부모 댓글 목록을 페이지 단위로 불러온다
    private func fetchPage(postId: Int,
                           cursor: String? = nil,
                           isRefresh: Bool = false) -> Observable<Mutation> {
        let fetch = Observable<Mutation>.create { [weak self] observer in
            let task = Task { [weak self] in
                do {
                    guard let self else {
                        observer.onCompleted()
                        return
                    }
                    let commentPage = try await self.fetchCommentListUseCase.execute(postId: postId, nextCursor: cursor)
                    self.page = commentPage.info
                    let editCase: CommentEdit = isRefresh ? .refresh(comments: commentPage.content) : .add(comments: commentPage.content)
                    let mutation = self.updateCommentList(editCase: editCase)
                    // 메인 카운트는 부모 댓글 수(totalCount)만 사용 — 대댓글은 제외
                    observer.onNext(.setCommentCount(commentPage.totalCount))
                    observer.onNext(mutation)
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
            }
            return Disposables.create { task.cancel() }
        }
        return requestWithLoading(task: fetch, defferredLoadingDelay: .seconds(0))
    }

    // MARK: - 대댓글 불러오기
    /// 대댓글 목록을 페이지 단위로 불러온다
    private func fetchReplyPage(postId: Int,
                                parentComment: Comment,
                                cursor: String? = nil,
                                isRefresh: Bool = false) -> Observable<Mutation> {
        guard let commentId = parentComment.id else { return .empty() }
        let fetch = Observable<Mutation>.create { [weak self] observer in
            let task = Task { [weak self] in
                do {
                    guard let self else {
                        observer.onCompleted()
                        return
                    }
                    let replyPage = try await self.fetchReplyCommentListUseCase.execute(postId: postId, commentId: commentId, nextCursor: cursor)
                    self.page = replyPage.info
                    let editCase: CommentEdit = isRefresh ? .refresh(comments: replyPage.content) : .add(comments: replyPage.content)
                    let mutation = self.updateCommentList(editCase: editCase)
                    observer.onNext(mutation)
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
            }
            return Disposables.create { task.cancel() }
        }
        return requestWithLoading(task: fetch, defferredLoadingDelay: .seconds(0))
    }
    
    // MARK: - 댓글 생성
    /// 새 댓글을 생성한다
    private func createComment(comment: String,
                               mentions: [Int] = []) -> Observable<Mutation> {
        guard let postId else { return .empty() }

        let createComment = Observable<Mutation>.create { [weak self] observer in
            let task = Task { [weak self] in
                do {
                    guard let self else {
                        observer.onCompleted()
                        return
                    }
                    let newComment = try await self.createCommentUseCase
                        .execute(postId: postId,
                                 comment: comment,
                                 mentions: mentions)
                    let mutation = self.updateCommentList(editCase: .create(comments: [newComment]))
                    observer.onNext(mutation)
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
            }
            return Disposables.create { task.cancel() }
        }

        return requestWithLoading(task: createComment)
            .concat(Observable.just(.adjustCommentCount(increment: true)))
    }

    // MARK: - 대댓글 생성
    /// 새 대댓글을 생성한다
    private func createReply(parentId: Int,
                             comment: String,
                             mentions: [Int] = []) -> Observable<Mutation> {
        guard let postId else { return .empty() }

        let createReply = Observable<Mutation>.create { [weak self] observer in
            let task = Task { [weak self] in
                do {
                    guard let self else {
                        observer.onCompleted()
                        return
                    }
                    let newReply = try await self.createReplyUseCase
                        .execute(postId: postId,
                                 parentId: parentId,
                                 comment: comment,
                                 mentions: mentions)
                    let mutation = self.updateCommentList(editCase: .create(comments: [newReply]))
                    observer.onNext(mutation)
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
            }
            return Disposables.create { task.cancel() }
        }

        return requestWithLoading(task: createReply)
            .concat(Observable.just(.adjustCommentCount(increment: true)))
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
    /// 기존 댓글을 수정한다
    private func editComment(comment: Comment,
                             text: String,
                             mentions: [Int] = []) -> Observable<Mutation> {
        guard let id = comment.id else { return .empty() }

        let editComment = Observable<Mutation>.create { [weak self] observer in
            let task = Task { [weak self] in
                do {
                    guard let self else {
                        observer.onCompleted()
                        return
                    }
                    let edited = try await self.editCommentUseCase
                        .execute(id: id,
                                 text: text,
                                 mentions: mentions)
                    let mutation = self.updateCommentList(editCase: .edit(comment: edited))
                    observer.onNext(mutation)
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
            }
            return Disposables.create { task.cancel() }
        }

        return requestWithLoading(task: editComment)
    }

    // MARK: - 댓글 삭제
    /// 댓글을 삭제한다
    private func deleteComment(comment: Comment) -> Observable<Mutation> {
        guard let selectedCommentId = comment.id else { return .empty() }

        let deleteComment = Observable<Mutation>.create { [weak self] observer in
            let task = Task { [weak self] in
                do {
                    try await self?.deleteCommentUseCase
                        .execute(commentId: selectedCommentId)
                    if let mutation = self?.updateCommentList(editCase: .delete(id: selectedCommentId)) {
                        observer.onNext(mutation)
                    }
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
            }
            return Disposables.create { task.cancel() }
        }

        return requestWithLoading(task: deleteComment)
            .concat(Observable.just(.adjustCommentCount(increment: false)))
    }
    
    // MARK: - 댓글 신고
    /// 댓글을 신고한다
    private func reportComment(comment: Comment) -> Observable<Mutation> {
        guard let id = comment.id else { return .empty() }

        return Observable<Mutation>.create { [weak self] observer in
            let task = Task { [weak self] in
                do {
                    try await self?.reportUseCase
                        .execute(type: .comment(id: id), reason: nil)
                    observer.onNext(.reportedComment)
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
            }
            return Disposables.create { task.cancel() }
        }
    }
    
    // MARK: - 댓글 좋아요
    private func likeComment(comment: Comment) -> Observable<Mutation> {
        guard let id = comment.id else { return .empty() }

        return Observable<Mutation>.create { [weak self] observer in
            let task = Task { [weak self] in
                do {
                    let updatedComment = try await self?.likeCommentUseCase.execute(commentId: id)
                    if let updatedComment {
                        observer.onNext(.updateComment(
                            self?.currentState.comments.map { $0.id == id ? updatedComment : $0 } ?? []
                        ))
                        // 답글 페이지에서 상단 고정된 '부모(메인) 댓글'에 좋아요를 누른 경우,
                        // 메인 댓글 페이지에도 좋아요 상태를 반영한다.
                        self?.syncParentCommentToMain(updatedComment)
                    }
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
            }
            return Disposables.create { task.cancel() }
        }
    }

    /// 답글 페이지에서 상단 고정된 부모 댓글의 변경(좋아요 등)을 메인 댓글 페이지로 전파한다.
    /// - 답글 페이지(.child)에서, 변경된 댓글이 해당 부모 댓글일 때만 동작한다.
    private func syncParentCommentToMain(_ comment: Comment) {
        guard case let .child(parent, _) = type,
              comment.id == parent.id else { return }
        coordinator?.updateParentComment(comment)
    }

    // MARK: - 댓글 리스트 편집
    private func updateCommentList(editCase: CommentEdit) -> Mutation {
        var comments = currentState.comments
        switch editCase {
        case .add(let commentList):
            setAddCommnetCommentList(comments: commentList, list: &comments)
        case .create(let commentList):
            setCreatedCommentList(comments: commentList, list: &comments)
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
    
    // MARK: - 새로 작성한 댓글 추가
    /// 새로 작성한 댓글을 목록에 반영한다.
    /// - 부모 댓글: 목록이 최신순이므로 상단에 삽입한다 (페이지네이션 append와 구분).
    /// - 대댓글: 부모 우선 + 날짜 오름차순 정렬이므로 기존 add 로직(하단 추가 후 정렬)을 재사용한다.
    private func setCreatedCommentList(comments newComments: [Comment], list: inout [Comment]) {
        switch type {
        case .parent:
            list.insert(contentsOf: newComments, at: 0)
        case let .child(parent, _):
            setAddCommnetCommentList(comments: newComments, list: &list)
            // 답글이 추가되면 메인 댓글 페이지의 부모 댓글 '답글 N개'를 +1 한다.
            if let parentId = parent.id {
                coordinator?.updateReplyCount(parentId: parentId, increment: true)
            }
        }
    }

    private func setFirstCommentList(comments: [Comment], list: inout [Comment]) {
        switch type {
        case .parent:
            list = comments
        case let .child(parent, _):
            // 답글 페이지는 부모(메인) 댓글을 상단에 고정하고 그 아래로 답글을 표시한다.
            // 서버 응답에는 답글만 내려오므로, 부모 댓글을 직접 맨 앞에 시드한다.
            // (이미 갱신된 부모가 리스트에 있으면 그 상태를 유지)
            let pinnedParent = list.first { $0.type == .parent } ?? parent
            list = [pinnedParent] + comments
        }
    }
    
    private func editComment(comments: inout [Comment], comment: Comment) {
        guard let editIndex = comments.firstIndex(where: { $0.id == comment.id }) else { return }
        comments[editIndex] = comment
    }

    // MARK: - 부모 댓글 답글 수 갱신
    /// 답글 페이지에서 전달받은 답글 수 변동을 메인 댓글 리스트의 해당 부모 댓글에 반영한다.
    private func updateParentReplyCount(parentId: Int, increment: Bool) -> Mutation {
        var comments = currentState.comments
        if let index = comments.firstIndex(where: { $0.id == parentId }) {
            let newCount = comments[index].replyCount + (increment ? 1 : -1)
            comments[index].replyCount = max(newCount, 0)
        }
        return .updateComment(comments)
    }
    
    private func handleDeleteComment(comments: inout [Comment], id: Int) {
        if case .child(let parent, _) = type, parent.id == id {
            coordinator?.deleteParentComment(id: id)
        } else {
            comments.removeAll { $0.id == id }
            // 답글 페이지에서 답글이 삭제되면 메인 댓글 페이지의 부모 댓글 '답글 N개'를 -1 한다.
            if case let .child(parent, _) = type, let parentId = parent.id {
                coordinator?.updateReplyCount(parentId: parentId, increment: false)
            }
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
