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
    func startAppleLogin() -> Single<String>
}

final class DefaultAppleLoginService: NSObject, AppleLoginService {
    
    private weak var presentationContextProvider: ASAuthorizationControllerPresentationContextProviding?
    private var singleObserver: ((SingleEvent<String>) -> Void)?
    
    func setPresentationContextProvider(_ view: UIViewController) {
        let loginView = view as? ASAuthorizationControllerPresentationContextProviding
        self.presentationContextProvider = loginView
    }
    
    func startAppleLogin() -> Single<String> {
        return Single.create { [weak self] single in
            guard let self = self else { return Disposables.create() }
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self.presentationContextProvider
            authorizationController.performRequests()
            
            self.singleObserver = single
            
            return Disposables.create()
        }
    }
}

extension DefaultAppleLoginService: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
           let identityToken = appleIDCredential.identityToken {
            let identityCode = String(decoding: identityToken, as: UTF8.self)
            singleObserver?(.success(identityCode))
        } else {
            singleObserver?(.failure(LoginError.noAuthCode))
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        singleObserver?(.failure(LoginError.completeError))
    }
}
