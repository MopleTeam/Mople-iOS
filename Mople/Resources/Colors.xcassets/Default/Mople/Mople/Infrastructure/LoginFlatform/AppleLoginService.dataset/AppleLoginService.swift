//
//  AppleLoginService.swift
//  Group
//
//  Created by CatSlave on 8/20/24.
//

import Foundation
import RxSwift
import AuthenticationServices

protocol AppleLoginService {
    func setPresentationContextProvider(_ view: UIViewController)
    func startAppleLogin() -> Single<SocialInfo>
}

final class DefaultAppleLoginService: NSObject, AppleLoginService {
    
    private weak var presentationContextProvider: ASAuthorizationControllerPresentationContextProviding?
    private var loginObserver: ((SingleEvent<SocialInfo>) -> Void)?
    
    override init() {
        super.init()
        print(#function, #line, "LifeCycle Test DefaultAppleLoginService Created" )
    }
    
    deinit {
        print(#function, #line, "LifeCycle Test DefaultAppleLoginService Deinit" )
    }
    
    func setPresentationContextProvider(_ view: UIViewController) {
        let loginView = view as? ASAuthorizationControllerPresentationContextProviding
        self.presentationContextProvider = loginView
    }
    
    func startAppleLogin() -> Single<SocialInfo> {
        return Single.create { [weak self] single in
            guard let self = self else { return Disposables.create() }
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self.presentationContextProvider
            authorizationController.performRequests()
            
            self.loginObserver = single
            
            return Disposables.create()
        }
    }
}

extension DefaultAppleLoginService: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
           let identityToken = appleIDCredential.identityToken {
            let identityCode = String(decoding: identityToken, as: UTF8.self)
            
            guard let email = fetchAppleEmail(appleIDCredential.email) else {
                loginObserver?(.failure(LoginError.appleAccountError))
                return
            }

            loginObserver?(.success(.init(provider: LoginPlatform.apple.rawValue,
                                           token: identityCode,
                                           email: email)))
        } else {
            loginObserver?(.failure(LoginError.appleAccountError))
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        if let authError = error as? ASAuthorizationError,
           authError.code == .canceled {
            loginObserver?(.failure(LoginError.cancle))
        } else {
            loginObserver?(.failure(LoginError.completeError))
        }
    }
    
    private func fetchAppleEmail(_ email: String?) -> String? {
        if let email = email,
           !email.isEmpty {
            saveEmail(email)
        }
        
        return getEmail()
    }
    
    private func saveEmail(_ email: String?) {
        guard let email,
              !email.isEmpty else { return  }
        
        KeychainStorage.shared.saveEmail(email)
    }
    
    private func getEmail() -> String? {
        KeychainStorage.shared.getEmail()
    }
}

