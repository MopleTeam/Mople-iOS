//
//  ProfileSetupViewModel.swift
//  Group
//
//  Created by CatSlave on 8/25/24.
//

import UIKit
import ReactorKit

struct ProfileSetupAction {
    var completed: () -> Void
}

enum ProfileSetupFacingMessage: Error {
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

final class ProfileFormViewReactor: Reactor {

    enum Action {
        case getRandomNickname
        case checkNickname(name: String)
        case setProfile(profile: (name: String?, image: UIImage?))
    }
    
    enum Mutation {
        case setLoading(isLoad: Bool)
        case getRandomNickname(name: String?)
        case nameCheck(isOverlap: Bool?)
        case madeProfile
        case notifyMessage(message: String?)
    }
    
    struct State {
        @Pulse var randomName: String?
        @Pulse var nameOverlap: Bool?
        @Pulse var message: String?
        @Pulse var isLoading: Bool = false
        @Pulse var buttonLoading: (status: Bool, tag: Int)?
        @Pulse var setupCompleted: Void?
    }
    
    private let profileRepository: ProfileRepository
    private var completedAction: ProfileSetupAction
    
    var initialState: State = State()
    
    init(profileRepository: ProfileRepository,
         completedAction: ProfileSetupAction) {
        self.profileRepository = profileRepository
        self.completedAction = completedAction
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        guard !currentState.isLoading else { return .empty()}
        
        switch action {
        case .getRandomNickname:
            return getRandomNickname()
        case .checkNickname(let name):
            return nickNameValidCheck(name: name)
        case .setProfile(let profile) :
            return makeProfile(profile.name, profile.image)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case .setLoading(let isLoad):
            newState.isLoading = isLoad
        case .getRandomNickname(let name):
            newState.randomName = name
        case .nameCheck(let isOverlap):
            newState.nameOverlap = isOverlap
        case .madeProfile:
            newState.setupCompleted = ()
            completedAction.completed()
        case .notifyMessage(let message):
            newState.message = message
        }
        
        return newState
    }
    
    func handleError(err: Error) -> String {
        var newState = state

        switch err {
        case let err as DataTransferError:
            let dataError = mapDataErrorToFacingError(err: err)
            return dataError.info
        case let err as TokenError:
            let tokenError = mapTokenErrorToFacingError(err: err)
            return tokenError.info
        case let err as ProfileSetupFacingMessage:
            return err.info
        default:
            return ProfileSetupFacingMessage.unknownError(err: err).info
        }
    }
}

extension ProfileFormViewReactor {
    private func mapTokenErrorToFacingError(err : TokenError) -> ProfileSetupFacingMessage {
        return .noTokenError
    }
    
    private func mapDataErrorToFacingError(err : DataTransferError) -> ProfileSetupFacingMessage {
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
    
    private func mapServerErrorToFacingError(err: ServerError) -> ProfileSetupFacingMessage {
        switch err {
        case .httpRespon(_):
            return .serverError
        case .errRespon(let message):
            return .errRespon(message: message)
        }
    }
}

extension ProfileFormViewReactor {
    
    private func getRandomNickname() -> Observable<Mutation> {
        let loadStart = Observable.just(Mutation.setLoading(isLoad: true))
        
        let randomName = profileRepository.getRandomNickname()
            .map({ String(data: $0, encoding: .utf8) })
            .asObservable()
            .map { Mutation.getRandomNickname(name: $0) }
            .catch {
                Observable.just(Mutation.notifyMessage(message: self.handleError(err: $0)))
            }
        
        let loadEnd = Observable.just(Mutation.setLoading(isLoad: false))
            
        return Observable.concat([loadStart,
                                  randomName,
                                  loadEnd])
    }
    
    private func nickNameValidCheck(name: String) -> Observable<Mutation> {
        
        let valid = Validator.checkNickname(name)
        
        switch valid {
        case .success:
            return nicknameDuplicateCheck(name)
        default:
            return Observable.just(Mutation.notifyMessage(message: valid.info))
        }
    }
    
    private func nicknameDuplicateCheck(_ name: String) -> Observable<Mutation> {
        let loadingOn = Observable.just(Mutation.setLoading(isLoad: true))
                
        #warning("서버에서 중복 결과를 true, false 뭘로 주는지 물어보기, 현재는 true")
        let nameOverlap = profileRepository.checkNickname(name: name)
            .asObservable()
            .map { Mutation.nameCheck(isOverlap: $0)}
            .catch {
                Observable.just(Mutation.notifyMessage(message: self.handleError(err: $0)))
            }
        
        let loadingOff = Observable.just(Mutation.setLoading(isLoad: false))
            
        return Observable.concat([loadingOn,
                                  nameOverlap,
                                  loadingOff])
    }
    
    private func makeProfile(_ name: String?,_ image: UIImage?) -> Observable<Mutation> {
        guard let name else { return .empty() }
        let image = image?.jpegData(compressionQuality: 0.7) ?? getDefaultImageData()
        
        let loadingOn = Observable.just(Mutation.setLoading(isLoad: true))
        
        let makeProfile = profileRepository.makeProfile(image: image, nickname: name)
            .asObservable()
            .map({ _ in Mutation.madeProfile })
            .catch {
                Observable.just(Mutation.notifyMessage(message: self.handleError(err: $0)))
            }
        
        let loadingOff = Observable.just(Mutation.setLoading(isLoad: false))
            
        return Observable.concat([loadingOn,
                                  makeProfile,
                                  loadingOff])
    }
}

extension ProfileFormViewReactor {
    private func getDefaultImageData() -> Data {
        let defaultImage: UIImage = .defaultIProfile
        let convertData = defaultImage.jpegData(compressionQuality: 0.5)
        return convertData ?? Data()
    }
}
