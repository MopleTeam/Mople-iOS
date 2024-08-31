//
//  ProfileSetupViewModel.swift
//  Group
//
//  Created by CatSlave on 8/25/24.
//

import Foundation
import ReactorKit
import RxSwift
import RxRelay

struct SignInAction {
    var completedSignIn: () -> Void
}

enum ProfileSetupFacingError: Error {
    case noTokenError
    case completedError
    case networkError
    case serverError
    case errRespon(message: String?)
    case parsingError
    case unknownError(err: Error)
    case retryEnter
    
    var info: String {
        switch self {
        case .noTokenError:
            "Apple ID 정보를 확인하고\n다시 시도해 주세요"
        case .completedError:
            "중복 확인에 실패했습니다.\n잠시 후 다시 시도해 주세요."
        case .unknownError(_):
            "알 수 없는 오류가 발생했습니다.\n잠시 후 다시 시도해 주세요."
        case .networkError:
            "네트워크 연결을 확인해주세요."
        case .serverError:
            "서버에 문제가 발생했습니다.\n잠시 후 다시 시도해 주세요."
        case .parsingError:
            "데이터에 문제가 발생했습니다.\n앱을 최신 버전으로 업데이트해 주세요."
        case .retryEnter:
            "입력 정보를 확인해주세요."
        case .errRespon(let message):
            message ?? "요청에 실패했습니다.\n잠시 후 다시 시도해 주세요."
        }
    }
}

final class ProfileSetupViewReactor: Reactor {

    enum Action {
        case getRandomNickname
        case checkNickname(name: String)
        case selectedImage(image: Data)
        case enterNickName(nickName: String)
        case makeProfile
    }
    
    enum Mutation {
        case getRandomNickname(name: String?)
        case nameCheck(isOverlap: Bool?)
        case setSelectedImage(image: Data)
        case setNickName(name : String)
        case madeProfile
        case catchError(err: Error)
        case setLoading(isLoad: Bool, type: ButtonType)
    }
    
    enum ButtonType {
        case check
        case next
    }
    
    struct State {
        @Pulse var isLoading: (status: Bool, type: ButtonType)?
        @Pulse var nameOverlap: Bool?
        @Pulse var errorMessage: String?
        @Pulse var madeProfile: Void?
        @Pulse var profileImageData: Data?
        @Pulse var profileNickName: String?
        @Pulse var randomName: String?
    }
    
    private let profileSetupUseCase: ProfileSetup
    private let signInAction: SignInAction
    
    var initialState: State = State()
    
    init(profileSetupUseCase: ProfileSetup, signInAction: SignInAction) {
        self.profileSetupUseCase = profileSetupUseCase
        self.signInAction = signInAction
        action.onNext(.getRandomNickname)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
        if let isLoading = currentState.isLoading {
            guard !isLoading.status else { return Observable.empty() }
        }

        switch action {
        case .getRandomNickname:
            return getRandomNickname()
        case .checkNickname(let name):
            return overlapCheck(name: name)
        case .makeProfile :
            return makeProfile()
        case .selectedImage(let image):
            return Observable.just(.setSelectedImage(image: image))
        case .enterNickName(let nickName):
            return Observable.just(.setNickName(name: nickName))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case .setLoading(let isLoad, let type):
            newState.isLoading = (isLoad, type)
        case .getRandomNickname(let name):
            newState.randomName = name
        case .nameCheck(let isOverlap):
            newState.nameOverlap = isOverlap
        case .catchError(err: let err):
            newState = handleError(state: newState, err: err)
        case .setSelectedImage(let image):
            newState.profileImageData = image
        case .setNickName(let name):
            newState.profileNickName = name
        case .madeProfile:
            signInAction.completedSignIn()
        }
        
        return newState
    }
    
    func handleError(state: State, err: Error) -> State {
        var newState = state

        switch err {
        case let err as DataTransferError:
            let dataError = mapDataErrorToFacingError(err: err)
            newState.errorMessage = dataError.info
        case let err as TokenError:
            let tokenError = mapTokenErrorToFacingError(err: err)
            newState.errorMessage = tokenError.info
        case let err as ProfileSetupFacingError:
            newState.errorMessage = err.info
        default:
            newState.errorMessage = ProfileSetupFacingError.unknownError(err: err).info
        }
        return newState
    }
}

extension ProfileSetupViewReactor {
    private func mapTokenErrorToFacingError(err : TokenError) -> ProfileSetupFacingError {
        return .noTokenError
    }
    
    private func mapDataErrorToFacingError(err : DataTransferError) -> ProfileSetupFacingError {
        switch err {
        case .parsing(_): .parsingError
        case .noResponse: .completedError
        case .networkFailure(_): .networkError
        case .resolvedNetworkFailure(let err):
            switch err {
            case let err as ServerError:
                mapServerErrorToFacingError(err: err)
            default:
                    .unknownError(err: err)
            }
        }
    }
    
    private func mapServerErrorToFacingError(err: ServerError) -> ProfileSetupFacingError {
        switch err {
        case .httpRespon(_):
            return .serverError
        case .errRespon(let message):
            return .errRespon(message: message)
        }
    }
}

extension ProfileSetupViewReactor {
    
    private func getRandomNickname() -> Observable<Mutation> {
        let randomName = profileSetupUseCase.getRandomNickname()
            .asObservable()
            .map { Mutation.getRandomNickname(name: $0) }
            
        return randomName
    }
    
    private func overlapCheck(name: String) -> Observable<Mutation> {
        
        let loadingOn = Observable.just(Mutation.setLoading(isLoad: true, type: .check))
        
        let enterNickName = Observable.just(Mutation.setNickName(name: name))
        
        let nameOverlap = profileSetupUseCase.checkNickName(name: name)
            .do(onSuccess: { print("중복 여부 : \($0)") })
            .asObservable()
            .map { Mutation.nameCheck(isOverlap: $0)}
            .catch { Observable.just(Mutation.catchError(err: $0)) }
        
        let loadingOff = Observable.just(Mutation.setLoading(isLoad: false, type: .check))
            
        return Observable.concat([loadingOn,
                                  enterNickName,
                                  nameOverlap,
                                  loadingOff])
    }
    
    private func makeProfile() -> Observable<Mutation> {
        let loadingOn = Observable.just(Mutation.setLoading(isLoad: true, type: .next))
        
        let image = currentState.profileImageData ?? getDefaultImageData()
        
        guard let nickName = currentState.profileNickName else {
            return Observable.just(Mutation.catchError(err: ProfileSetupFacingError.retryEnter))
        }
        
        let makeProfile = profileSetupUseCase.makeProfile(image: image, nickName: nickName)
            .asObservable()
            .map({ _ in Mutation.madeProfile })
            .catch { Observable.just(Mutation.catchError(err: $0)) }
        
        let loadingOff = Observable.just(Mutation.setLoading(isLoad: false, type: .next))
            
        return Observable.concat([loadingOn,
                                  makeProfile,
                                  loadingOff])
    }
}

extension ProfileSetupViewReactor {
    private func getDefaultImageData() -> Data {
        guard let image = AppDesign.Profile.defaultImage,
              let imageData = image.jpegData(compressionQuality: 0.5) else { return Data() }
        
        return imageData
    }
}
