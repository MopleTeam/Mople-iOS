//
//  ReviewViewReactor.swift
//  Mople
//
//  Created by CatSlave on 2/6/25.
//
import UIKit
import Kingfisher
import ReactorKit

enum ReviewEditError: Error {
    case noResponse(ResponseError)
    case failSelectPhoto(CompressionPhotosError)
    case unknown(Error)
}

final class ReviewEditViewReactor: Reactor, LifeCycleLoggable {
    
    enum Action {
        enum Flow {
            case showMemberList
            case endFlow
        }
        
        case deleteImage(Int)
        case showImagePicker
        case fetchReview(Review)
        case loadImage
        case updateReview
        case flow(Flow)
    }
    
    enum Mutation {
        case updateReviewInfo(Review)
        case updateLoadingState(Bool)
        case updateImage([ImageWrapper])
        case updateCompleteAvaliable(Bool)
        case catchError(ReviewEditError)
    }
    
    struct State {
        @Pulse var images: [ImageWrapper] = []
        @Pulse var review: Review?
        @Pulse var canComplete: Bool = false
        @Pulse var isLoading: Bool = false
        @Pulse var error: ReviewEditError?
    }
    
    // MARK: - Variables
    var initialState: State = State()
    private var review: Review
    private var existingImageIds: [String] = []
    
    // MARK: - UseCase
    private let deleteReviewImage: DeleteReviewImage
    private let imageUpload: ReviewImageUpload
    
    // MARK: - Photo
    private let photoService: PhotoService
    
    // MARK: - Coordinator
    private weak var coordiantor: ReviewEditViewCoordination?
    
    // MARK: - LifeCycle
    init(review: Review,
         deleteReviewImage: DeleteReviewImage,
         imageUpload: ReviewImageUpload,
         photoService: PhotoService,
         coordinator: ReviewEditViewCoordination) {
        self.review = review
        self.deleteReviewImage = deleteReviewImage
        self.imageUpload = imageUpload
        self.photoService = photoService
        self.coordiantor = coordinator
        initialAction()
        logLifeCycle()
    }
    
    deinit {
        logLifeCycle()
    }
    
    // MARK: - Intial Setup
    private func initialAction() {
        action.onNext(.fetchReview(review))
        action.onNext(.loadImage)
    }
    
    // MARK: - State Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .fetchReview(review):
            return .just(.updateReviewInfo(review))
        case .loadImage:
            return loadImage()
        case let .deleteImage(index):
            return deleteImage(index: index)
        case let .flow(action):
            return handleFlowAction(action)
        case .showImagePicker:
            return selectedImage()
        case .updateReview:
            return updateReview()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case let .updateReviewInfo(review):
            newState.review = review
        case let .updateImage(images):
            newState.images = images
        case let .updateLoadingState(isLoading):
            newState.isLoading = isLoading
        case let .updateCompleteAvaliable(isAvaliable):
            newState.canComplete = isAvaliable
        case let .catchError(error):
            newState.error = error
        }
        
        return newState
    }
}

// MARK: - Data Request
extension ReviewEditViewReactor {
    
    // MARK: - 이미지 불러오기
    private func loadImage() -> Observable<Mutation> {
        guard review.images.isEmpty == false else { return .empty() }
        
        let imageObservers: [Observable<ImageWrapper>] = Observable.reviewImagesTaskBuilder(review.images)
        
        let updateImage = Observable.zip(imageObservers)
            .do(onNext: { [weak self] images in
                let ids = images.compactMap { $0.id }
                self?.existingImageIds = ids
            })
            .map { Mutation.updateImage($0) }
        
        return requestWithLoading(task: updateImage)
    }
    
    // MARK: - 이미지 편집하기
    private func updateReview() -> Observable<Mutation> {
        guard let id = review.id else { return .empty() }
        let requestUpdate = requestAddImage(id: id)
            .flatMap({ [weak self] _ -> Observable<Void> in
                guard let self else { return .empty() }
                return requsetDeleteImage(id: id)
            })
            .observe(on: MainScheduler.instance)
            .flatMap { [weak self] _ -> Observable<Mutation> in
                self?.postUpdateImage()
                self?.coordiantor?.endFlow()
                return .empty()
            }
        
        return requestWithLoading(task: requestUpdate)
    }
    
    private func requestAddImage(id: Int) -> Observable<Void> {
        let addImages = currentState.images
            .filter { $0.isNew }
            .map { $0.image }
        
        guard !addImages.isEmpty else {
            return .just(())
        }
        
        return imageUpload
            .execute(id: id,
                     images: addImages)
    }
    
    private func requsetDeleteImage(id: Int) -> Observable<Void> {
        let currentImageId: [String] = currentState.images.compactMap { $0.id }
        let deleteImageId: [String] = existingImageIds.filter { !currentImageId.contains($0) }
        
        guard !deleteImageId.isEmpty else {
            return .just(())
        }
        
        return deleteReviewImage
            .execute(reviewId: id, imageIds: deleteImageId)
    }

    // MARK: - 이미지 업데이트
    private func selectedImage() -> Observable<Mutation> {
        guard currentState.images.count < 5 else { return .empty() }
        
        let limit = 5 - currentState.images.count
        photoService.updatePhotoLimit(limit)
        
        return photoService.presentImagePicker()
            .asObservable()
            .map({ [weak self] selecteImages -> [ImageWrapper] in
                guard let self else { return []}
                let images = imageWrapping(selecteImages, isNew: true)
                var currentImage = currentState.images
                currentImage.append(contentsOf: images)
                return currentImage
            })
            .flatMap { [weak self] imageWraaper -> Observable<Mutation> in
                guard let self else { return .empty() }
                return updateImageState(imageWraaper)
            }
    }
    
    private func deleteImage(index: Int) -> Observable<Mutation> {
        var currentImage = currentState.images
        currentImage.remove(at: index)
        return updateImageState(currentImage)
    }
 
    private func updateImageState(_ images: [ImageWrapper]) -> Observable<Mutation> {
        let editImages = Mutation.updateImage(images)
        let isNew = checkNewImage(images)
        let updateCompleteAvailable = Mutation.updateCompleteAvaliable(isNew)
        return .of(editImages, updateCompleteAvailable)
    }
    
    /// 사진편집 여부
    /// - Parameter images: 편집된 사진
    /// - Returns: 기존의 사진이 삭제되었거나 새로운 사진이 추가되었다면 true
    private func checkNewImage(_ images: [ImageWrapper]) -> Bool {
        let isDeleteExistingImage = images.count < existingImageIds.count
        let isAddedImage = images.contains { $0.isNew == true }
        return isDeleteExistingImage || isAddedImage
    }

    // MARK: - 이미지 랩핑
    private func imageWrapping(_ images: [UIImage], isNew: Bool) -> [ImageWrapper] {
        return images.map { ImageWrapper(image: $0, isNew: isNew) }
    }
}

// MARK: - Notify
extension ReviewEditViewReactor {
    private func postUpdateImage() {
        NotificationManager.shared.post(name: .postReview)
    }
}

// MARK: - Coordination
extension ReviewEditViewReactor {
    private func handleFlowAction(_ action: Action.Flow) -> Observable<Mutation> {
        switch action {
        case .showMemberList:
            coordiantor?.pushMemberListView()
        case .endFlow:
            coordiantor?.endFlow()
        }
        
        return .empty()
    }
}

// MARK: - Loading & Error
extension ReviewEditViewReactor: LoadingReactor {
    func updateLoadingMutation(_ isLoading: Bool) -> Mutation {
        return .updateLoadingState(isLoading)
    }
    
    func catchErrorMutation(_ error: Error) -> Mutation {
        let err = handleError(error)
        return .catchError(err)
    }
    
    private func handleError(_ err: Error) -> ReviewEditError {
        switch err {
        case let requestError as DataRequestError:
            guard let responseError = handleDataRequestError(err: requestError) else {
                return .unknown(err)
            }
            return .noResponse(responseError)
        case let photoError as CompressionPhotosError:
            return .failSelectPhoto(photoError)
        default:
            return .unknown(err)
        }
    }
    
    private func handleDataRequestError(err: DataRequestError) -> ResponseError? {
        guard let meetId = review.meet?.id else { return nil }
        return DataRequestError.resolveNoResponseError(err: err,
                                                       responseType: .meet(id: meetId))
    }
}



