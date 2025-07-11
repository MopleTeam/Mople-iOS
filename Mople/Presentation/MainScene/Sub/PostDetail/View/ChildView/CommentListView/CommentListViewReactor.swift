//
//  CommentListViewReactor.swift
//  Mople
//
//  Created by CatSlave on 1/16/25.
//
import UIKit
import ReactorKit

protocol CommentListCommands: AnyObject {
    func loadComment(postId: Int)
    func refreshComment()
    func writeComment(comment: String)
    func completeEditComment()
    func addPhotoList(_ photoPaths: [UIImage])
}

final class CommentListViewReactor: Reactor, LifeCycleLoggable {
    
    enum Action {
        enum ParentCommand {
            case fetchComment(postId: Int)
            case refreshComment
            case writeComment(comment: String)
            case addPhotoList([UIImage])
            case completedRefreshed
        }
        
        enum ChildEvent {
            case showHistory(startIndex: Int)
            case showUserImage(imagePath: String?)
            case offsetChanged(_ offsetY: CGFloat)
            case editComment
            case refreshPost
        }

        case parentCommand(ParentCommand)
        case childEvent(ChildEvent)
        case selctedComment(comment: Comment?)
        case deleteComment
        case reportComment
        case moreComment
    }
    
    enum Mutation {
        case fetchedSectionModel([CommentTableSectionModel])
        case fetchedPage(PageInfo?)
        case createdComment
        case completedRefreshed
    }
    
    struct State {
        @Pulse var sectionModels: [CommentTableSectionModel] = []
        @Pulse var pageInfo: PageInfo?
        @Pulse var createdCompletion: Void?
        @Pulse var isRefreshed: Void?
    }
    
    // MARK: - Variables
    var initialState: State = State()
    private var postId: Int?
    private var selectedComment: Comment?
    private var lastCurosr: String?
    
    // MARK: - UseCase
    private let fetchCommentListUseCase: FetchCommentList
    private let createCommentUseCase: CreateComment
    private let deleteCommentUseCase: DeleteComment
    private let editCommentUseCase: EditComment
    private let reportUseCase: ReportPost
    
    // MARK: - Delegate
    private weak var delegate: CommentListDelegate?
    
    // MARK: - LifeCycle
    init(fetchCommentListUseCase: FetchCommentList,
         createCommentUseCase: CreateComment,
         deleteCommentUseCase: DeleteComment,
         editCommentUseCase: EditComment,
         reportUseCase: ReportPost,
         delegate: CommentListDelegate) {
        self.fetchCommentListUseCase = fetchCommentListUseCase
        self.createCommentUseCase = createCommentUseCase
        self.deleteCommentUseCase = deleteCommentUseCase
        self.editCommentUseCase = editCommentUseCase
        self.reportUseCase = reportUseCase
        self.delegate = delegate
        logLifeCycle()
    }
    
    deinit {
        logLifeCycle()
    }
    
    // MARK: - State Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .parentCommand(command):
            return handleParentCommand(command)
        case let .childEvent(event):
            return handleChildEvent(event)
        case let .selctedComment(comment):
            return self.selectedComment(comment)
        case .deleteComment:
            return deleteComment()
        case .reportComment:
            return reportComment()
        case .moreComment:
            return moreComment()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case let .fetchedSectionModel(models):
            newState.sectionModels = models
        case let .fetchedPage(pageInfo):
            newState.pageInfo = pageInfo
        case .createdComment:
            newState.createdCompletion = ()
        case .completedRefreshed:
            newState.isRefreshed = ()
        }
        return newState
    }
}

// MARK: - Action Handling
extension CommentListViewReactor {
    
    // MARK: - 부모 -> 자식
    private func handleParentCommand(_ command: Action.ParentCommand) -> Observable<Mutation> {
        switch command {
        case let .fetchComment(postId):
            return fetchCommentWithLoading(postId: postId)
        case let .writeComment(comment):
            return handleWriteComment(comment: comment)
        case let .addPhotoList(photoList):
            let addSection = addPhotoSectionModel(photoList)
            return .just(addSection)
        case .completedRefreshed:
            return .just(.completedRefreshed)
        case .refreshComment:
            return refreshComment()
        }
    }
    
    // MARK: - 자식 -> 부모
    private func handleChildEvent(_ event: Action.ChildEvent) -> Observable<Mutation> {
        switch event {
        case .editComment:
            editComment()
        case let .offsetChanged(offsetY):
            changedCommentListTableOffsetY(offsetY)
        case let .showHistory(index):
            showPhotoBook(index: index)
        case .refreshPost:
            refreshData()
        case let .showUserImage(imagePath):
            showUserImage(imagePath)
        }
        
        return .empty()
    }
    
    private func changedCommentListTableOffsetY(_ offset: CGFloat) {
        self.delegate?.setCommentListTableOffsetY(offset)
    }
    
    private func editComment() {
        guard let text = selectedComment?.comment else { return }
        self.delegate?.editComment(text)
    }
    
    private func showPhotoBook(index: Int) {
        delegate?.showReviewPhoto(index: index)
    }
    
    private func showUserImage(_ imagePath: String?) {
        delegate?.showUserImage(imagePath: imagePath)
    }
    
    private func refreshData() {
        delegate?.refresh()
    }
}

// MARK: - Data Request
extension CommentListViewReactor {
    
    // MARK: - 댓글 불러오기
    private func fetchComment(postId: Int,
                              isRefresh: Bool = false,
                              cursor: String? = nil) -> Observable<Mutation> {
        return fetchCommentListUseCase.execute(postId: postId, nextCursor: cursor)
            .flatMap({ [weak self] commentPage -> Observable<Mutation> in
                guard let self else { return .empty() }
                let addSection = addCommentSectionModel(commentPage.content, isRefresh: isRefresh)
                let page = Mutation.fetchedPage(commentPage.page)
                return .of(addSection, page)
            })
    }
    
    private func fetchCommentWithLoading(postId: Int) -> Observable<Mutation> {
        updatePostId(postId)
        let fetch = fetchComment(postId: postId)
        return requestWithLoading(task: fetch)
    }
    
    private func moreComment() -> Observable<Mutation> {
        guard let postId,
              let cursor = currentState.pageInfo?.nextCursor,
              lastCurosr != cursor else { return .empty() }
        return fetchComment(postId: postId, cursor: cursor)
            .do(onCompleted: { [weak self] in
                self?.lastCurosr = cursor
            })
    }
    
    private func refreshComment() -> Observable<Mutation> {
        guard let postId else { return .empty() }
        lastCurosr = nil
        return fetchComment(postId: postId,
                                isRefresh: true)
        .concat(Observable.just(.completedRefreshed))
    }
    
    private func updatePostId(_ postId: Int)  {
        guard self.postId == nil else { return }
        self.postId = postId
    }
    
    // MARK: - 댓글 편집 핸들링
    private func handleWriteComment(comment: String) -> Observable<Mutation> {
        return Observable.just(comment)
            .flatMap { [weak self] comment -> Observable<Mutation> in
                guard let self else { return .empty() }
                
                if let selectedCommentId = self.selectedComment?.id {
                    return self.editComment(commentId: selectedCommentId,
                                            comment: comment)
                } else {
                    return self.createComment(comment: comment)
                }
            }
    }
    
    // MARK: - 댓글 생성
    private func createComment(comment: String) -> Observable<Mutation> {
        
        guard let postId else { return .empty() }
        
        let createComment = createCommentUseCase
            .execute(postId: postId,
                     comment: comment)
            .flatMap({ [weak self] comments -> Observable<Mutation> in
                guard let self else { return .empty() }
                self.selectedComment = nil
                delegate?.editComment(nil)
                return .just(addCommentSectionModel(comments))
            })

        return requestWithLoading(task: createComment)
            .flatMap { addSection -> Observable<Mutation> in
                return .of(addSection, .createdComment)
            }
    }
    
    // MARK: - 댓글 편집
    private func editComment(commentId: Int,
                                comment: String) -> Observable<Mutation> {
        
        guard let postId else { return .empty() }
        
        let editComment = editCommentUseCase
            .execute(postId: postId,
                     commentId: commentId,
                     comment: comment)
            .flatMap({ [weak self] comments -> Observable<Mutation> in
                guard let self else { return .empty() }
                self.selectedComment = nil
                delegate?.editComment(nil)
                return .just(addCommentSectionModel(comments))
            })
        
        return requestWithLoading(task: editComment)
    }

    // MARK: - 댓글 삭제 및 리로드
    private func deleteComment() -> Observable<Mutation> {
        
        guard let selectedCommentId = self.selectedComment?.id else { return .empty() }
        
        let deleteComment = deleteCommentUseCase
            .execute(commentId: selectedCommentId)
            .flatMap { [weak self] _ -> Observable<Mutation> in
                guard let self,
                      let postId else { return .empty() }
                selectedComment = nil
                return fetchComment(postId: postId)
            }
        
        return requestWithLoading(task: deleteComment)
    }
    
    // MARK: - 댓글 신고
    private func reportComment() -> Observable<Mutation> {
        guard let id = self.selectedComment?.id else { return .empty() }
        
        let reportComment = reportUseCase
            .execute(type: .comment(id: id), reason: nil)
            .flatMap({ [weak self] _ -> Observable<Mutation> in
                self?.selectedComment = nil
                self?.delegate?.reportComment()
                return .empty()
            })
        
        return requestWithLoading(task: reportComment)
    }
}

// MARK: - Section bulider
extension CommentListViewReactor {
    private func findSectionIndex(type: SectionType) -> Int? {
        return currentState.sectionModels.firstIndex { $0.type == type }
    }
    
    // MARK: - Comment Section
    private func addCommentSectionModel(_ comment: [Comment],
                                        isRefresh: Bool = false) -> Mutation {
        var sectionModels = currentState.sectionModels
        let items = comment.map { SectionItem.comment($0) }
    
        if isRefresh {
            resetCommentSection(sections: &sectionModels,
                                newItems: items)
        } else {
            appendCommentSection(sections: &sectionModels,
                                 newItems: items)
        }
        return .fetchedSectionModel(sectionModels)
    }
    
    private func resetCommentSection(sections: inout [CommentTableSectionModel], newItems: [SectionItem]) {
        sections.removeAll { $0.type == .commentList }
        let model = CommentTableSectionModel(type: .commentList, items: newItems)
        sections.append(model)
    }
    
    private func appendCommentSection(sections: inout [CommentTableSectionModel], newItems: [SectionItem]) {
        if let sectionIndex = findSectionIndex(type: .commentList) {
            sections[sectionIndex].items.append(contentsOf: newItems)
        } else {
            let model = CommentTableSectionModel(type: .commentList, items: newItems)
            sections.append(model)
        }
    }
    
    // MARK: - Photo Section
    private func addPhotoSectionModel(_ photos: [UIImage]) -> Mutation {
        var sectionModels = currentState.sectionModels

        if photos.isEmpty {
            removePhotoSection(sections: &sectionModels)
        } else {
            appendPhotoSection(sections: &sectionModels,
                               photos: photos)
        }
        return .fetchedSectionModel(sectionModels)
    }
    
    private func removePhotoSection(sections: inout [CommentTableSectionModel]) {
        sections.removeAll { $0.type == .photoList }
    }
    
    private func appendPhotoSection(sections: inout [CommentTableSectionModel], photos: [UIImage]) {
        let newItem = SectionItem.photo(photos)
        let photoSection = CommentTableSectionModel(type: .photoList, items: [newItem])
        if let sectionIndex = findSectionIndex(type: .photoList) {
            sections[sectionIndex] = photoSection
        } else {
            sections.insert(photoSection, at: 0)
        }
    }
}

// MARK: - Commands
extension CommentListViewReactor: CommentListCommands {
    
    func loadComment(postId: Int) {
        action.onNext(.parentCommand(.fetchComment(postId: postId)))
    }
    
    func writeComment(comment: String) {
        action.onNext(.parentCommand(.writeComment(comment: comment)))
    }
    
    func completeEditComment() {
        selectedComment = nil
    }
    
    func addPhotoList(_ photos: [UIImage]) {
        action.onNext(.parentCommand(.addPhotoList(photos)))
    }
    
    func refreshComment() {
        action.onNext(.parentCommand(.refreshComment))
    }
}

// MARK: - Helper
extension CommentListViewReactor {
    private func selectedComment(_ comment: Comment?) -> Observable<Mutation> {
        self.selectedComment = comment
        return .empty()
    }
}

// MARK: - Loading & Error
extension CommentListViewReactor: ChildLoadingReactor {
    var parent: ChildLoadingDelegate? { delegate }
}
