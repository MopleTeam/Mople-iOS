//
//  CommentListViewReactor.swift
//  Mople
//
//  Created by CatSlave on 1/16/25.
//
import UIKit
import ReactorKit

protocol CommentListCommands: AnyObject {
    func writeComment(comment: String)
    func cancleEditComment()
    func addPhotoList(_ photoPaths: [String])
}

enum CommentViewError: Error {
    
}

final class CommentListViewReactor: Reactor, LifeCycleLoggable {
    
    enum Action {
        enum ParentCommand {
            case write(comment: String)
            case addPhotoList(_ photoPaths: [String])
        }
        
        enum ChildEvent {
            case editComment
            case offsetChanged(_ offsetY: CGFloat)
        }

        case parentCommand(ParentCommand)
        case childEvent(ChildEvent)
        case loadCommentList
        case selctedComment(comment: Comment?)
        case deleteComment
    }
    
    enum Mutation {
        case fetchedSectionModel([CommentTableSectionModel])
        case createCompletion
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
    private weak var delegate: CommentListDelegate?
    private let postId: Int
    private var selectedComment: Comment?
    
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
        action.onNext(.loadCommentList)
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
        case .loadCommentList:
            return self.fetchingCommentList()
        case let .selctedComment(comment):
            return self.selectedComment(comment)
        case .deleteComment:
            return self.deletingComment()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case let .fetchedSectionModel(models):
            newState.sectionModels = models
        case .createCompletion:
            newState.createdCompletion = ()
        }
        return newState
    }
}

// MARK: - 액션 핸들링
extension CommentListViewReactor {
    private func handleParentCommand(_ command: Action.ParentCommand) -> Observable<Mutation> {
        switch command {
        case let .write(comment):
            return handleWriteComment(comment: comment)
        case let .addPhotoList(photoList):
            return addPhotoSectionModel(photoList)
        }
    }
    
    private func handleChildEvent(_ event: Action.ChildEvent) -> Observable<Mutation> {
        switch event {
        case .editComment:
            return editComment()
        case let .offsetChanged(offsetY):
            return changedCommentListTableOffsetY(offsetY)
        }
    }
}

// MARK: - 데이터 로드
extension CommentListViewReactor {
    
    private func fetchingCommentList() -> Observable<Mutation> {
        
        let loadingStart = self.setLoading(true)
        
        let loadingStop = self.setLoading(false)
        
        return .concat([loadingStart,
                        fetchCommentList(),
                        loadingStop])
    }
    
    private func handleWriteComment(comment: String) -> Observable<Mutation> {
        return Observable.just(comment)
            .flatMap { [weak self] comment in
                guard let self else { throw AppError.unknownError }
                
                if let previousCommentId = self.selectedComment?.id {
                    return self.editingComment(previousCommentId: previousCommentId, comment: comment)
                } else {
                    return self.creatingComment(comment: comment)
                }
            }
    }
    
    private func creatingComment(comment: String) -> Observable<Mutation> {
        print(#function, #line)
        return withDeferredLoading(task: createComment(comment),
                                   completeMutaion: .createCompletion)
    }
    
    private func editingComment(previousCommentId: Int, comment: String) -> Observable<Mutation> {
        print(#function, #line)
        return withDeferredLoading(task: editComment(previousCommentId: previousCommentId,
                                                     comment: comment))
    }
    
    private func deletingComment() -> Observable<Mutation> {
        return withDeferredLoading(task: deleteComment())
    }
}

// MARK: - 댓글 CRUD
extension CommentListViewReactor {
    private func fetchCommentList() -> Observable<Mutation> {
        return self.fetchCommentListUseCase.execute(postId: postId)
            .asObservable()
            .map({ $0.sorted(by: <) })
            .map({ [weak self] comments in
                guard let self else { throw AppError.unknownError }
                let sectionModels = addCommentSectionModel(comments)
                return Mutation.fetchedSectionModel(sectionModels)
            })
    }
    
    private func createComment(_ comment: String) -> Observable<Mutation> {
        return self.createCommentUseCase
            .execute(postId: postId,
                     comment: comment)
            .asObservable()
            .map({ $0.sorted(by: <) })
            .map({ [weak self] comments in
                guard let self else { throw AppError.unknownError }
                let sectionModels = addCommentSectionModel(comments)
                return Mutation.fetchedSectionModel(sectionModels)
            })
    }
    
    private func editComment(previousCommentId: Int, comment: String) -> Observable<Mutation> {
        return self.editCommentUseCase
            .execute(postId: postId, commentId: previousCommentId, comment: comment)
            .asObservable()
            .do(onNext: { [weak self] _ in
                self?.selectedComment = nil
            })
            .map({ $0.sorted(by: <) })
            .map({ [weak self] comments in
                guard let self else { throw AppError.unknownError }
                let sectionModels = addCommentSectionModel(comments)
                return Mutation.fetchedSectionModel(sectionModels)
            })
    }
    
    private func deleteComment() -> Observable<Mutation> {
        guard let selectedCommentId = selectedComment?.id else { return .empty() }
        
        return self.deleteCommentUseCase
            .execute(commentId: selectedCommentId)
            .asObservable()
            .do(onNext: { [weak self] _ in
                self?.selectedComment = nil
            })
            .flatMap { [weak self] in
                guard let self else { throw AppError.unknownError }
                return self.fetchCommentList()
            }
    }
}

// MARK: - Helper
extension CommentListViewReactor {
    private func selectedComment(_ comment: Comment?) -> Observable<Mutation> {
        self.selectedComment = comment
        return .empty()
    }
}

// MARK: - To Parents
extension CommentListViewReactor {
    
    /// 작업 완료 후 일정시간 뒤 로딩종료
    private func withDeferredLoading(task: Observable<Mutation>,
                                     delay: RxTimeInterval = .milliseconds(100),
                                     completeMutaion: Mutation? = nil) -> Observable<Mutation> {
        let loadingStart = self.setLoading(true)
        
        let loadingStop = Observable.just(())
            .delay(delay, scheduler: MainScheduler.instance)
            .do(onNext: { [weak self] _ in
                self?.delegate?.commentListLoading(false)
            })
            .flatMap({ _ in
                guard let completeMutaion else { return Observable<Mutation>.empty() }
                return Observable.just(completeMutaion)
            })
        
        return .concat([loadingStart,
                        task,
                        loadingStop])
    }
    
    /// 상위 뷰에게 로딩이 끝났음을 전달
    private func setLoading(_ isLoading: Bool) -> Observable<Mutation>{
        self.delegate?.commentListLoading(isLoading)
        return .empty()
    }
    
    private func changedCommentListTableOffsetY(_ offset: CGFloat) -> Observable<Mutation> {
        self.delegate?.setCommentListTableOffsetY(offset)
        return .empty()
    }
    
    // MARK: - Comment Edit
    private func editComment() -> Observable<Mutation> {
        guard let text = selectedComment?.comment else { return .empty() }
        self.delegate?.editComment(text)
        return .empty()
    }
}

// MARK: - 리스트 섹션 모델
extension CommentListViewReactor {
    private func addCommentSectionModel(_ comment: [Comment]) -> [CommentTableSectionModel] {
        var sectionModels = currentState.sectionModels
        let sectionItems = comment.map { SectionItem.comment($0) }
        let sectionModel = CommentTableSectionModel(type: .commentList, items: sectionItems)
        if let commentSectionIndex = sectionModels.firstIndex(
            where: { $0.type == .commentList }) {
            sectionModels[commentSectionIndex] = sectionModel
        } else {
            sectionModels.append(sectionModel)
        }
        return sectionModels
    }
    
    private func addPhotoSectionModel(_ photoPaths: [String]) -> Observable<Mutation> {
        let sectionItem = SectionItem.photo(photoPaths)
        let sectionModel = CommentTableSectionModel(type: .photoList, items: [sectionItem])
        var sectionModels = currentState.sectionModels
        sectionModels.insert(sectionModel, at: 0)
        return .just(.fetchedSectionModel(sectionModels))
    }
}

// MARK: - 부모뷰 명령
extension CommentListViewReactor: CommentListCommands {
    func addPhotoList(_ photoPaths: [String]) {
        guard photoPaths.isEmpty == false else { return }
        action.onNext(.parentCommand(.addPhotoList(photoPaths)))
    }
    
    func writeComment(comment: String) {    
        action.onNext(.parentCommand(.write(comment: comment)))
    }
    
    func cancleEditComment() {
        selectedComment = nil
    }
}
