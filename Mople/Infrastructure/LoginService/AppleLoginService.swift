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
    func startAppleLogin() -> Single<SocialAccountInfo>
}

final class DefaultAppleLoginService: NSObject, AppleLoginService {
    
    private weak var presentationContextProvider: ASAuthorizationControllerPresentationContextProviding?
    private var singleObserver: ((SingleEvent<SocialAccountInfo>) -> Void)?
    
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
    
    func startAppleLogin() -> Single<SocialAccountInfo> {
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
            
            print(#function, #line, "# 29 : \(appleIDCredential.email)" )
            
            guard let email = fetchAppleEmail(appleIDCredential.email) else {
                singleObserver?(.failure(LoginError.appleAccountError))
                return
            }

            singleObserver?(.success(.init(platform: LoginPlatform.apple.rawValue,
                                           identityCode: identityCode,
                                           email: email)))
        } else {
            singleObserver?(.failure(LoginError.appleAccountError))
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        singleObserver?(.failure(LoginError.completeError))
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
        
        KeyChainService.shared.saveEmail(email)
    }
    
    private func getEmail() -> String? {
        KeyChainService.shared.getEmail()
    }
}
