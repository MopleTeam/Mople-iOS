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
}

enum CommentViewError: Error {
    
}

final class CommentListViewReactor: Reactor, LifeCycleLoggable {
    
    enum Action {
        enum ParentCommand {
            case fetchCommentList(postId: Int)
            case writeComment(comment: String)
            case addPhotoList([UIImage])
        }
        
        enum ChildEvent {
            case editComment
            case offsetChanged(_ offsetY: CGFloat)
            case selectedPhoto(Int)
            case reportComment
        }

        case parentCommand(ParentCommand)
        case childEvent(ChildEvent)
        case selctedComment(comment: Comment?)
        case deleteComment
    }
    
    enum Mutation {
        enum ParentRequest {
            case createdComment
            case editedComment
            case reportComment
        }
        
        case fetchedSectionModel([CommentTableSectionModel])
        case requestParent(ParentRequest)
    }
    
    struct State {
        @Pulse var sectionModels: [CommentTableSectionModel] = []
        @Pulse var createdCompletion: Void?
    }
    
    var initialState: State = State()
    
    private let fetchCommentListUseCase: FetchCommentList
    private let createCommentUseCase: CreateComment
    private let deleteCommentUseCase: DeleteComment
    private let editCommentUseCase: EditComment
    private let reportUseCase: ReportPost
    private weak var delegate: CommentListDelegate?
    private var postId: Int?
    private var selectedComment: Comment?
    
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
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case let .fetchedSectionModel(models):
            if models.isEmpty == false {
                newState.sectionModels = models
            }
        case let .requestParent(request):
            handleDelegate(state: &newState,
                           request: request)
        }
        return newState
    }
    
    private func handleDelegate(state: inout State,
                                request: Mutation.ParentRequest) {
        switch request {
        case .createdComment:
            state.createdCompletion = ()
            delegate?.editComment(nil)
        case .editedComment:
            selectedComment = nil
            delegate?.editComment(nil)
        case .reportComment:
            selectedComment = nil
            delegate?.reportComment()
        }
    }
}

// MARK: - 액션 핸들링
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
        }
    }
    
    // MARK: - 자식 -> 부모
    private func handleChildEvent(_ event: Action.ChildEvent) -> Observable<Mutation> {
        switch event {
        case .editComment:
            return editComment()
        case let .offsetChanged(offsetY):
            return changedCommentListTableOffsetY(offsetY)
        case let .selectedPhoto(index):
            return showPhotoBook(index: index)
        case .reportComment:
            return reportComment()
        }
    }
    
    private func changedCommentListTableOffsetY(_ offset: CGFloat) -> Observable<Mutation> {
        self.delegate?.setCommentListTableOffsetY(offset)
        return .empty()
    }
    
    private func editComment() -> Observable<Mutation> {
        guard let text = selectedComment?.comment else { return .empty() }
        self.delegate?.editComment(text)
        return .empty()
    }
    
    private func showPhotoBook(index: Int) -> Observable<Mutation> {
        print(#function, #line)
        delegate?.showPhotoBook(index: index)
        return .empty()
    }
}

// MARK: - 데이터 로드
extension CommentListViewReactor {
    
    private func fetchCommentListWithLoading(postId: Int) -> Observable<Mutation> {
        
        updatePostId(postId)
        let fetchComment = fetchCommentList(postId: postId)
        return requestWithLoading(task: fetchComment)
    }
    
    private func fetchCommentList(postId: Int) -> Observable<Mutation> {
        return fetchCommentListUseCase.execute(postId: postId)
            .asObservable()
            .map({ $0.sorted(by: <) })
            .flatMap({ [weak self] comments -> Observable<Mutation> in
                guard let self else { return .empty() }
                let addSection = addCommentSectionModel(comments)
                return .just(addSection)
            })
    }
    
    private func updatePostId(_ postId: Int)  {
        guard self.postId == nil else { return }
        self.postId = postId
    }
    
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
    
    private func createComment(comment: String) -> Observable<Mutation> {
        
        guard let postId else { return .empty() }
        
        let createComment = createCommentUseCase
            .execute(postId: postId,
                     comment: comment)
            .asObservable()
            .map({ $0.sorted(by: <) })
            .flatMap({ [weak self] comments -> Observable<Mutation> in
                guard let self else { return .empty() }
                let addSection = addCommentSectionModel(comments)
                let requestParent = Mutation.requestParent(.createdComment)
                return .of(addSection, requestParent)
            })

        return requestWithLoading(task: createComment)
    }
    
    private func editComment(commentId: Int,
                                comment: String) -> Observable<Mutation> {
        
        guard let postId else { return .empty() }
        
        let editComment = editCommentUseCase
            .execute(postId: postId,
                     commentId: commentId,
                     comment: comment)
            .asObservable()
            .do(onNext: { [weak self] _ in
                self?.selectedComment = nil
            })
            .map({ $0.sorted(by: <) })
            .flatMap({ [weak self] comments -> Observable<Mutation> in
                guard let self else { return .empty() }
                let addSection = addCommentSectionModel(comments)
                let requestParent = Mutation.requestParent(.editedComment)
                return .of(addSection, requestParent)
            })
        
        return requestWithLoading(task: editComment)
    }
    
    private func deleteComment() -> Observable<Mutation> {
        
        guard let selectedCommentId = self.selectedComment?.id else { return .empty() }
        
        let deleteComment = deleteCommentUseCase
            .execute(commentId: selectedCommentId)
            .asObservable()
            .do(onNext: { [weak self] _ in
                self?.selectedComment = nil
            })
            .flatMap { [weak self] _ -> Observable<Mutation> in
                guard let self,
                      let postId else { return .empty() }
                return fetchCommentList(postId: postId)
            }
        
        return requestWithLoading(task: deleteComment)
    }
    
    private func reportComment() -> Observable<Mutation> {
        guard let id = self.selectedComment?.id else { return .empty() }
        
        let reportComment = reportUseCase
            .execute(type: .comment(id: id), reason: nil)
            .asObservable()
            .flatMap { Observable<Mutation>.just(.requestParent(.reportComment)) }
        
        return requestWithLoading(task: reportComment)
    }
}

// MARK: - Helper
extension CommentListViewReactor {
    private func selectedComment(_ comment: Comment?) -> Observable<Mutation> {
        self.selectedComment = comment
        return .empty()
    }
}

// MARK: - 리스트 섹션 모델
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

// MARK: - 부모뷰 명령
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
}

extension CommentListViewReactor: ChildLoadingReactor {
    var parent: ChildLoadingDelegate? { delegate }
}
