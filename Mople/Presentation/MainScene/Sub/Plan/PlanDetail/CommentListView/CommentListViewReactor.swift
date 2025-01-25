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
    func addPhotoList(_ photoPaths: [String?])
}

enum CommentViewError: Error {
    
}

final class CommentListViewReactor: Reactor, LifeCycleLoggable {
    
    enum Action {
        case loadCommentList
        case writeComment(comment: String)
        case selctedComment(comment: Comment?)
        case editComment
        case deleteComment
        case addPhotoList(_ photoPaths: [String?])
        case notifyStartOffsetY(CGFloat)
    }
    
    enum Mutation {
        case fetchedSectionModel([CommentTableSectionModel])
        case createCompletion
        case editCompletion(index: IndexPath?)
    }
    
    struct State {
        @Pulse var sectionModels: [CommentTableSectionModel] = []
        @Pulse var createdCompletion: Void?
        @Pulse var editCompletion: IndexPath?
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
        case .loadCommentList:
            return self.fetchingCommentList()
        case let .writeComment(comment):
            return self.handleWriteComment(comment: comment)
        case let .selctedComment(comment):
            return self.selectedComment(comment)
        case .editComment:
            return self.editComment()
        case .deleteComment:
            return self.deletingComment()
        case let .addPhotoList(photoPaths):
            return self.addPhotoSectionModel(photoPaths)
        case let .notifyStartOffsetY(offset):
            return self.setStartOffset(offset)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case let .fetchedSectionModel(models):
            newState.sectionModels = models
        case .createCompletion:
            newState.createdCompletion = ()
        case let .editCompletion(index):
            newState.editCompletion = index
        }
        return newState
    }
}

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
        return withDeferredLoading(task: createComment(comment),
                                   completeMutaion: .createCompletion)
    }
    
    private func editingComment(previousCommentId: Int, comment: String) -> Observable<Mutation> {
        let findEditCommentIndex = findCommentIndex(previousCommentId)
        
        return withDeferredLoading(task: editComment(previousCommentId: previousCommentId,
                                                     comment: comment),
                                   completeMutaion: .editCompletion(index: findEditCommentIndex))
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
    
    #warning("enum 연관값도 찾을 수 있음")
    private func findCommentIndex(_ commentId: Int) -> IndexPath? {
        let sectionModels = currentState.sectionModels
        guard let commentSectionIndex = sectionModels.firstIndex(where: { $0.type == .commentList }),
              let editCommentIndex = sectionModels[commentSectionIndex].items.firstIndex(where: { item in
                  guard case .comment(let comment) = item else { return false }
                  return comment.id == commentId
              }) else { return nil }

        return .init(row: editCommentIndex,
                     section: commentSectionIndex)
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
    
    private func setStartOffset(_ offset: CGFloat) -> Observable<Mutation> {
        self.delegate?.setStartOffsetY(offset)
        return .empty()
    }
    
    // MARK: - Comment Edit
    private func editComment() -> Observable<Mutation> {
        guard let text = selectedComment?.comment else { return .empty() }
        self.delegate?.editComment(text)
        return .empty()
    }
}

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
    
    private func addPhotoSectionModel(_ photoPaths: [String?]) -> Observable<Mutation> {
        let sectionItem = SectionItem.photo(photoPaths)
        let sectionModel = CommentTableSectionModel(type: .photoList, items: [sectionItem])
        var sectionModels = currentState.sectionModels
        sectionModels.insert(sectionModel, at: 0)
        return .just(.fetchedSectionModel(sectionModels))
    }
}

extension CommentListViewReactor: CommentListCommands {
    func addPhotoList(_ photoPaths: [String?]) {
        action.onNext(.addPhotoList(photoPaths))
    }
    
    func writeComment(comment: String) {    
        self.action.onNext(.writeComment(comment: comment))
    }
    
    func cancleEditComment() {
        self.selectedComment = nil
    }
}
