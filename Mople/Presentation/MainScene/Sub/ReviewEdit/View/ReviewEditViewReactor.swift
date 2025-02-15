//
//  ReviewViewReactor.swift
//  Mople
//
//  Created by CatSlave on 2/6/25.
//
import UIKit
import Kingfisher
import ReactorKit

final class ReviewEditViewReactor: Reactor {
    
    enum Action {
        enum Flow {
            case showMemberList
            case endFlow
        }
        
        case deleteImage(Int)
        case showImagePicker
        case fetchReview(Review)
        case fetchImage
        case updateReview
        case flow(Flow)
    }
    
    enum Mutation {
        case updateReviewInfo(Review)
        case updateLoadingState(Bool)
        case updateImage([ImageWrapper])
        case updateCompleteAvaliable(Bool)
        case catchError(Error)
    }
    
    struct State: LoadingState {
        @Pulse var images: [ImageWrapper] = []
        @Pulse var review: Review?
        @Pulse var canComplete: Bool = false
        @Pulse var message: String?
        @Pulse var isLoading: Bool = false
    }
    
    var initialState: State = State()
    
    private var review: Review
    private let fetchReviewImage: FetchReviewImage
    private let deleteReviewImage: DeleteReviewImage
    private let imageUpload: ReviewImageUpload
    private let photoService: PhotoService
    private weak var coordiantor: ReviewEditViewCoordination?
    private var existingImageIds: [String] = []
    
    init(review: Review,
         fetchReviewImage: FetchReviewImage,
         deleteReviewImage: DeleteReviewImage,
         imageUpload: ReviewImageUpload,
         photoService: PhotoService,
         coordinator: ReviewEditViewCoordination) {
        self.review = review
        self.fetchReviewImage = fetchReviewImage
        self.deleteReviewImage = deleteReviewImage
        self.imageUpload = imageUpload
        self.photoService = photoService
        self.coordiantor = coordinator
        initalSetup()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .fetchReview(review):
            return .just(.updateReviewInfo(review))
        case .fetchImage:
            return fetchImage()
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
            handleError(state: &newState,
                        error: error)
        }
        
        return newState
    }
    
    private func handleError(state: inout State, error: Error) {
        
    }
    
    private func initalSetup() {
        action.onNext(.fetchReview(review))
        action.onNext(.fetchImage)
    }
}

extension ReviewEditViewReactor {
    
    // MARK: - 이미지 불러오기
    private func fetchImage() -> Observable<Mutation> {
        guard let id = review.id else { return .empty() }
        
        let fetchImage = fetchReviewImage.execute(reviewId: id)
            .asObservable()
            .flatMap { [weak self] reviewImage -> Observable<Mutation> in
                guard let self else { return .empty() }
                return loadReviewImages(reviewImage)
            }
        
        return requestWithLoading(task: fetchImage)
    }
    
    private func loadReviewImages(_ reviewImage: [ReviewImage]) -> Observable<Mutation> {
        let imageObservers: [Observable<ImageWrapper>] = Observable.reviewImagesTaskBuilder(reviewImage)
        return Observable.zip(imageObservers)
            .do(onNext: { [weak self] images in
                let ids = images.compactMap { $0.id }
                self?.existingImageIds = ids
            })
            .map { Mutation.updateImage($0) }
    }
    
    // MARK: - 이미지 편집하기
    private func updateReview() -> Observable<Mutation> {
        guard let id = review.id else { return .empty() }
        let addImage = requestAppImage(id: id)
        let deleteImage = requsetDeleteImage(id: id)
        let requestUpdate = Observable.zip(addImage, deleteImage)
            .asObservable()
            .flatMap { _ -> Observable<Mutation> in
                return .empty()
            }
        
        return requestWithLoading(task: requestUpdate) { [weak self] in
            guard let self else { return }
            let images = currentState.images.map { $0.image }
            updateReviewState(images: images)
            notificationUpdateImage()
            coordiantor?.endFlow()
        }
    }
    
    private func updateReviewState(images: [UIImage]) {
        review.state = .updated(photos: images)
        review.images = images
        review.isReviewd = true
    }
    
    private func requestAppImage(id: Int) -> Observable<Void> {
        let addImages = currentState.images
            .filter { $0.isNew }
            .map { $0.image }

        if addImages.isEmpty == false {
            return imageUpload.execute(id: id,
                                       images: addImages)
                .asObservable()
                .flatMap { Observable.just(()) }
        } else {
            return .just(())
        }
    }
    
    private func requsetDeleteImage(id: Int) -> Observable<Void> {
        let currentImageId: [String] = currentState.images.compactMap { $0.id }
        let deleteImageId: [String] = existingImageIds.filter { !currentImageId.contains($0) }
        if deleteImageId.isEmpty == false {
            return deleteReviewImage.execute(reviewId: id, imageIds: deleteImageId)
                .asObservable()
                .flatMap { Observable.just(()) }
        } else {
            return .just(())
        }
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
            .flatMap(updateImageState(_:))
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

// MARK: - Notification
extension ReviewEditViewReactor {
    private func notificationUpdateImage() {
        EventService.shared.postItem(.updated(review),
                                     from: self)
    }
}

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

extension ReviewEditViewReactor: LoadingReactor {
    var loadingState: LoadingState { currentState }
    
    func updateLoadingState(_ isLoading: Bool) -> Mutation {
        return .updateLoadingState(isLoading)
    }
    
    func catchError(_ error: Error) -> Mutation {
        return .catchError(error)
    }
}



