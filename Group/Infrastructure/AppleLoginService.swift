//
//  AppleLoginService.swift
//  Group
//
//  Created by CatSlave on 8/20/24.
//

import Foundation
import RxSwift
import AuthenticationServices

//protocol AppleLoginServiceProtocol {
//    func setPresentationContextProvider(_ provider: ASAuthorizationControllerPresentationContextProviding)
//    func startAppleLogin()
//}
//
//class AppleLoginService: NSObject, AppleLoginServiceProtocol {
//    
//    let loginObservable: PublishSubject<String> = .init()
//    
//    private weak var presentationContextProvider: ASAuthorizationControllerPresentationContextProviding?
//
//    func setPresentationContextProvider(_ provider: ASAuthorizationControllerPresentationContextProviding) {
//        self.presentationContextProvider = provider
//    }
//
//    func startAppleLogin() {
//        
//        
//        let appleIDProvider = ASAuthorizationAppleIDProvider()
//        let request = appleIDProvider.createRequest()
//        request.requestedScopes = [.fullName, .email]
//
//        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
//        authorizationController.delegate = self
//        authorizationController.presentationContextProvider = presentationContextProvider
//        authorizationController.performRequests()
//    }
//}
//
//extension AppleLoginService: ASAuthorizationControllerDelegate {
//    
//    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
//        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
//           let authorizationCode = appleIDCredential.authorizationCode {
//            let codeString = String(decoding: authorizationCode, as: UTF8.self)
//            
//            self.loginObservable.onNext(codeString)
//        }
//    }
//
//    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
//        
//        self.loginObservable.onError(error)
//    }
//}
protocol AppleLoginService {
    func setPresentationContextProvider(_ view: UIViewController)
    func startAppleLogin() -> Single<String>
}

enum LoginError: Error {
    case noAuthCode
    case completeError
    
    var message: String {
        switch self {
        default: "로그인 실패"
        }
    }
}

class DefaultAppleLoginService: NSObject, AppleLoginService {
    
    private weak var presentationContextProvider: ASAuthorizationControllerPresentationContextProviding?

    func setPresentationContextProvider(_ view: UIViewController) {
        let loginView = view as? ASAuthorizationControllerPresentationContextProviding
        self.presentationContextProvider = loginView
    }

    func startAppleLogin() -> Single<String> {
        return Single.create { [weak self] single in
            guard let self = self else {
                single(.failure(NSError(domain: "AppleLoginService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Self is nil"])))
                return Disposables.create()
            }

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

    private var singleObserver: ((SingleEvent<String>) -> Void)?
}

extension DefaultAppleLoginService: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
           let authorizationCode = appleIDCredential.authorizationCode {
            let codeString = String(decoding: authorizationCode, as: UTF8.self)
            
            singleObserver?(.success(codeString))
        } else {
            singleObserver?(.failure(LoginError.noAuthCode))
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        singleObserver?(.failure(LoginError.completeError))
    }
}
