//
//  ProfileSetupViewModel.swift
//  Group
//
//  Created by CatSlave on 8/25/24.
//

import UIKit
import ReactorKit

enum ProfileSetupType {
    case create(SocialInfo)
    case update(UserInfo)
}

class ProfileSetupViewReactor: Reactor {

    enum Action {
        case setName(_ name: String?)
        case setImage(_ image: UIImage?)
        case setPreviousProfile(_ profile: UserInfo)
        case generatorName
        case duplicateCheck(name: String)
    }
    
    enum Mutation {
        case updateName(_ name: String?)
        case updateImage(_ image: UIImage?)
        case updateDuplication(_ isDuplication: Bool?)
        case randomName(_ name: String)
        case updatePreviousProfile(_ profile: UserInfo?)
        
        case isDuplicationEnabled(_ enabled: Bool)
        case isCompletionEnalbed(_ enabled: Bool)
        
        case notifyMessage(message: String?)
        case setLoading(isLoad: Bool)
    }
    
    struct State {
        @Pulse var name: String?
        @Pulse var image: UIImage?
        @Pulse var generatorName: String?
        @Pulse var isDuplicationName: Bool?
        @Pulse var message: String?
        @Pulse var isLoading: Bool = false
        @Pulse var previousProfile: UserInfo?
        @Pulse var canCheckDuplication: Bool = false
        @Pulse var canCheckCompletion: Bool = false
    }
    
    private let validativeNickname: ValidationNickname
    private var generateNickname: CreationNickname?
    
    var initialState: State = State()
    
    init(profile: UserInfo? = nil,
         validativeNickname: ValidationNickname,
         generateNickname: CreationNickname? = nil) {
        print(#function, #line, "LifeCycle Test ProfileSetup Reactor Created" )
        self.validativeNickname = validativeNickname
        self.generateNickname = generateNickname
        self.setDefaultProfile(profile)
    }
    
    private func setDefaultProfile(_ profile: UserInfo?) {
        if let profile {
            self.action.onNext(.setPreviousProfile(profile))
        } else {
            self.action.onNext(.generatorName)
        }
    }
    
    deinit {
        print(#function, #line, "LifeCycle Test ProfileSetup Reactor Deinit" )
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
        switch action {
        case .duplicateCheck(let name):
            return nickNameValidCheck(name: name)
        case .generatorName:
            return generatorName()
        case let .setPreviousProfile(profile):
            return .just(.updatePreviousProfile(profile))
        case let .setName(name):
            return updateNickname(name)
        case let .setImage(image):
            return updateImage(image)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case let .updateDuplication(isDuplication):
            newState.isDuplicationName = isDuplication
        case let .notifyMessage(message):
            newState.message = message
        case let .setLoading(isLoad):
            newState.isLoading = isLoad
        case let .randomName(name):
            newState.name = name
            newState.generatorName = name
        case let .updatePreviousProfile(profile):
            newState.name = profile?.name
            newState.previousProfile = profile
        
        case let .updateName(name):
            newState.name = name
        case let .updateImage(image):
            newState.image = image
            
        case let .isDuplicationEnabled(isEnabled):
            newState.canCheckDuplication = isEnabled
        case let .isCompletionEnalbed(isEnabled):
            newState.canCheckCompletion = isEnabled
        }
        
        return newState
    }
    
    func handleError(err: Error) -> String {
        switch err {
        case NetworkError.notConnected:
            return AppError.networkError.info
        default:
            return AppError.unknownError.info
        }
    }
}

extension ProfileSetupViewReactor {
    
    private func generatorName() -> Observable<Mutation> {
        guard let generateNickname else { return .empty() }
        
        let loadingOn = Observable.just(Mutation.setLoading(isLoad: true))
        
        let generatorName = generateNickname.executue()
            .asObservable()
            .compactMap({ $0 })
            .map { Mutation.randomName($0)}
            .catch { [weak self] err in
                return Observable.just(Mutation.notifyMessage(message: self?.handleError(err: err)))
            }
        
        let loadingOff = Observable.just(Mutation.setLoading(isLoad: false))
        
        return Observable.concat([loadingOn,
                                  generatorName,
                                  loadingOff])
    }
    
    private func nickNameValidCheck(name: String) -> Observable<Mutation> {
        let loadingOn = Observable.just(Mutation.setLoading(isLoad: true))
        
        let nicknameValidator = validativeNickname.execute(name)
            .asObservable()
            .map { Mutation.updateDuplication($0)}
            .catch { [weak self] err in
                return Observable.just(Mutation.notifyMessage(message: self?.handleError(err: err)))
            }
        
        let loadingOff = Observable.just(Mutation.setLoading(isLoad: false))
        return Observable.concat([loadingOn,
                                  nicknameValidator,
                                  loadingOff])
    }
    
    private func updateNickname(_ name: String?) -> Observable<Mutation> {
        let updateName = Observable.just(Mutation.updateName(name))
        
        let resetDuplication = Observable.just(Mutation.updateDuplication(nil))
        
        let updateDuplicateAvailable = isDuplicateCheckAvailable(name: name)
        
        return .concat([updateName,
                        resetDuplication,
                        updateDuplicateAvailable])
    }
    
    private func updateImage(_ image: UIImage?) -> Observable<Mutation> {
        let updateImage = Observable.just(Mutation.updateImage(image))
        
        let updateCompleteAvailable = isCompleteAvailable()
        
        return .concat([updateImage,
                        updateCompleteAvailable])
    }
    
    private func isDuplicateCheckAvailable(name: String?) -> Observable<Mutation> {
        guard let name,
              Validator.checkNickname(name) else {
            return .just(Mutation.isDuplicationEnabled(false))
        }
        
        if let previousName = self.currentState.previousProfile?.name {
            let isChangedName = previousName != name
            return .just(Mutation.isDuplicationEnabled(isChangedName))
        } else {
            return .just(Mutation.isDuplicationEnabled(true))
        }
    }
    
    private func isCompleteAvailable() -> Observable<Mutation> {
        guard let previousName = self.currentState.previousProfile?.name,
              let inputName = self.currentState.name else {
            return .empty()
        }
        
        let isUnchangedName = previousName == inputName
        let isValidName = currentState.isDuplicationName == true
        
        return .just(Mutation.isCompletionEnalbed(isUnchangedName || isValidName))
    }
}

