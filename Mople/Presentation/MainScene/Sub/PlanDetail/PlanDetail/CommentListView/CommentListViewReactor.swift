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
    func addPhotoList(_ photoPaths: [UIImage])
}

enum CommentViewError: Error {
    
}

final class CommentListViewReactor: Reactor, LifeCycleLoggable {
    
    enum Action {
        enum ParentCommand {
            case write(comment: String)
            case addPhotoList([UIImage])
        }
        
        enum ChildEvent {
            case editComment
            case offsetChanged(_ offsetY: CGFloat)
            case selectedPhoto(Int)
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
            if models.isEmpty == false {
                newState.sectionModels = models
            }
        case .createCompletion:
            newState.createdCompletion = ()
        }
        return newState
    }
}

// MARK: - 액션 핸들링
extension CommentListViewReactor {
    
    // MARK: - 부모 -> 자식
    private func handleParentCommand(_ command: Action.ParentCommand) -> Observable<Mutation> {
        switch command {
        case let .write(comment):
            return handleWriteComment(comment: comment)
        case let .addPhotoList(photoList):
            return addPhotoSectionModel(photoList)
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
        }
    }
    
    private func setLoading(_ isLoading: Bool) -> Observable<Mutation>{
        self.delegate?.commentListLoading(isLoading)
        return .empty()
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
        delegate?.showPhotoBook(index: index)
        return .empty()
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
            .flatMap({ [weak self] comments -> Observable<Mutation> in
                guard let self else { return .empty() }
                return addCommentSectionModel(comments)
            })
    }
    
    private func createComment(_ comment: String) -> Observable<Mutation> {
        return self.createCommentUseCase
            .execute(postId: postId,
                     comment: comment)
            .asObservable()
            .map({ $0.sorted(by: <) })
            .flatMap({ [weak self] comments -> Observable<Mutation> in
                guard let self else { return .empty() }
                return addCommentSectionModel(comments)
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
            .flatMap({ [weak self] comments -> Observable<Mutation> in
                guard let self else { return .empty() }
                return addCommentSectionModel(comments)
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
}

// MARK: - 리스트 섹션 모델
extension CommentListViewReactor {
    private func addCommentSectionModel(_ comment: [Comment]) -> Observable<Mutation> {
        let sectionItems = comment.map { SectionItem.comment($0) }
        let sectionModel = CommentTableSectionModel(type: .commentList, items: sectionItems)
        let addedSection = addSectionModel(model: sectionModel)
        return .just(.fetchedSectionModel(addedSection))
    }
    
    private func addPhotoSectionModel(_ photos: [UIImage]) -> Observable<Mutation> {
        let sectionItem = SectionItem.photo(photos)
        let sectionModel = CommentTableSectionModel(type: .photoList, items: [sectionItem])
        let addedSection = addSectionModel(model: sectionModel)
        return .just(.fetchedSectionModel(addedSection))
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
                guard case .photo(let image) = model.items.first else {
                    return sectionModels
                }
                if image.isEmpty {
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
            models.insert(model, at: 0)
        }
    }
}

// MARK: - 부모뷰 명령
extension CommentListViewReactor: CommentListCommands {
    func addPhotoList(_ photos: [UIImage]) {
        action.onNext(.parentCommand(.addPhotoList(photos)))
    }
    
    func writeComment(comment: String) {    
        action.onNext(.parentCommand(.write(comment: comment)))
    }
    
    func cancleEditComment() {
        selectedComment = nil
    }
}
