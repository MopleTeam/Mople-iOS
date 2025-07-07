//
//  CommentListViewReactor.swift
//  Mople
//
//  Created by CatSlave on 1/16/25.
//
import UIKit
import ReactorKit

protocol CommentListCommands: AnyObject {
    func fetchComment(postId: Int)
    func writeComment(comment: String)
    func completeEditComment()
    func addPhotoList(_ photoPaths: [UIImage])
    func completedRefreshed()
}

final class CommentListViewReactor: Reactor, LifeCycleLoggable {
    
    enum Action {
        enum ParentCommand {
            case fetchCommentList(postId: Int)
            case writeComment(comment: String)
            case addPhotoList([UIImage])
            case completedRefreshed
        }
        
        enum ChildEvent {
            case showHistory(startIndex: Int)
            case showUserImage(imagePath: String?)
            case offsetChanged(_ offsetY: CGFloat)
            case editComment
            case refresh
        }

        case parentCommand(ParentCommand)
        case childEvent(ChildEvent)
        case selctedComment(comment: Comment?)
        case deleteComment
        case reportComment
    }
    
    enum Mutation {
        case fetchedSectionModel([CommentTableSectionModel])
        case createdComment
        case completedRefreshed
    }
    
    struct State {
        @Pulse var sectionModels: [CommentTableSectionModel] = []
        @Pulse var createdCompletion: Void?
        @Pulse var isRefreshed: Void?
    }
    
    // MARK: - Variables
    var initialState: State = State()
    private var postId: Int?
    private var selectedComment: Comment?
    
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
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case let .fetchedSectionModel(models):
            newState.sectionModels = models
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
        case let .fetchCommentList(postId):
            return fetchCommentListWithLoading(postId: postId)
        case let .writeComment(comment):
            return handleWriteComment(comment: comment)
        case let .addPhotoList(photoList):
            let addSection = addPhotoSectionModel(photoList)
            return .just(addSection)
        case .completedRefreshed:
            return .just(.completedRefreshed)
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
        case .refresh:
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
    private func fetchCommentList(postId: Int) -> Observable<Mutation> {
        
        return fetchCommentListUseCase.execute(postId: postId)
            .catchAndReturn([])
            .flatMap({ [weak self] comments -> Observable<Mutation> in
                guard let self else { return .empty() }
                let addSection = addCommentSectionModel(comments)
                return .just(addSection)
            })
    }
    
    private func fetchCommentListWithLoading(postId: Int) -> Observable<Mutation> {
        updatePostId(postId)
        let fetchComment = fetchCommentList(postId: postId)
        return requestWithLoading(task: fetchComment)
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
                return fetchCommentList(postId: postId)
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
    private func addCommentSectionModel(_ comment: [Comment]) -> Mutation {
        let sectionItems = comment.map { SectionItem.comment($0) }
        let sectionModel = CommentTableSectionModel(type: .commentList, items: sectionItems)
        let addedSection = addSectionModel(model: sectionModel)
        return .fetchedSectionModel(addedSection)
    }
    
    private func addPhotoSectionModel(_ photos: [UIImage]) -> Mutation {
        let sectionItem = SectionItem.photo(photos)
        let sectionModel = CommentTableSectionModel(type: .photoList, items: [sectionItem])
        let addedSection = addSectionModel(model: sectionModel)
        return .fetchedSectionModel(addedSection)
    }
    
    /// 섹션유무에 따라서 업데이트 or 추가
    private func addSectionModel(model: CommentTableSectionModel) -> [CommentTableSectionModel] {
        var sectionModels = currentState.sectionModels
        
        if let sectionIndex = sectionModels.firstIndex(
            where: { $0.type == model.type }) {
            switch model.type {
            case .commentList:
                sectionModels[sectionIndex] = model
            case .photoList:
                guard case .photo(let images) = model.items.first else {
                    return sectionModels
                }
                if images.isEmpty {
                    sectionModels.remove(at: sectionIndex)
                } else {
                    sectionModels[sectionIndex] = model
                }
            }
        } else {
            handleAddSectionModel(model, models: &sectionModels)
        }
        return sectionModels
    }
    
    /// 섹션 추가 핸들링
    /// - Parameters:
    ///   - 섹션의 타입에 따라서 다른 방식으로 추가
    ///   - 포토뷰 : 0번 섹션 고정
    ///   - 댓글뷰 : 마지막 섹션
    private func handleAddSectionModel(_ model: CommentTableSectionModel,
                                       models: inout [CommentTableSectionModel]) {
        switch model.type {
        case .commentList:
            models.append(model)
        case .photoList:
            guard case .photo(let images) = model.items.first,
                  images.isEmpty == false else { return }
            models.insert(model, at: 0)
        }
    }
}

// MARK: - Commands
extension CommentListViewReactor: CommentListCommands {
    
    func fetchComment(postId: Int) {
        action.onNext(.parentCommand(.fetchCommentList(postId: postId)))
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
    
    func completedRefreshed() {
        action.onNext(.parentCommand(.completedRefreshed))
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
