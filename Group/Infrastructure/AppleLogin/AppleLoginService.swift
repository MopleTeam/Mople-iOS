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

enum LoginError: Error {
    case noAuthCode
    case completeError
}

class DefaultAppleLoginService: NSObject, AppleLoginService {
    
    private weak var presentationContextProvider: ASAuthorizationControllerPresentationContextProviding?
    private var singleObserver: ((SingleEvent<String>) -> Void)?
    
    func setPresentationContextProvider(_ view: UIViewController) {
        let loginView = view as? ASAuthorizationControllerPresentationContextProviding
        self.presentationContextProvider = loginView
    }
    
    func startAppleLogin() -> Single<String> {
        return Single.create { single in
            
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
           let authorizationCode = appleIDCredential.authorizationCode,
           let identityToken = appleIDCredential.identityToken {

            let authCode = String(decoding: authorizationCode, as: UTF8.self)
            let authCodeBase = authorizationCode.base64EncodedString()
            
            let identityCode = String(decoding: identityToken, as: UTF8.self)
            let identityCodeBase = identityToken.base64EncodedString()

            print(#function, #line, "apple login code, \n authCode(UTF8) : \(authCode) \n authBase: \(authCodeBase) \n identityCode(UTF8) : \(identityCode) \n identityBase: \(identityCodeBase)" )
            singleObserver?(.success(identityCode))
        } else {
            singleObserver?(.failure(LoginError.noAuthCode))
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        singleObserver?(.failure(LoginError.completeError))
    }
}


//if let jsonData = try? JSONSerialization.data(withJSONObject: authData),
//       let jsonString = String(data: jsonData, encoding: .utf8) {
//        print(#function, #line, "apple login data: \(jsonString)")

