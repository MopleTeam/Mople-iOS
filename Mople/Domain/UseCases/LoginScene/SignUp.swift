//
//  UploadImage.swift
//  Mople
//
//  Created by CatSlave on 11/28/24.
//

import UIKit
import RxSwift

protocol SignUp {
    func getRandomNickname() -> Single<String?>
    func signUp(nickname: String, image: UIImage?, socialAccountInfo: SocialAccountInfo) -> Single<Void>
}

final class SignUpUseCase: SignUp {
    
    let imageUploadRepo: ImageUploadRepo
    let signUpRepo: SignUpRepo
    
    init(imageUploadRepo: ImageUploadRepo,
         signUpRepo: SignUpRepo) {
        print(#function, #line, "LifeCycle Test SignUpUseCase Created" )

        self.imageUploadRepo = imageUploadRepo
        self.signUpRepo = signUpRepo
    }
    
    deinit {
        print(#function, #line, "LifeCycle Test SignUpUseCase Deinit" )
    }
}

// MARK: - Nickname Helper
extension SignUpUseCase {
    func getRandomNickname() -> Single<String?> {
        self.signUpRepo.getRandomNickname()
            .map { String(data: $0, encoding: .utf8)  }
    }
}

// MARK: - Sign Up
extension SignUpUseCase {
    func signUp(nickname: String,
                image: UIImage?,
                socialAccountInfo: SocialAccountInfo) -> Single<Void> {
        print(#function, #line)
        let imageData = self.convertImageToData(image)
        return self.uploadImage(imageData)
            .map { $0.isEmpty ? nil : $0 }
            .flatMap { [weak self] imagePath in
                guard let self else { throw AppError.unknownError }
                return self.signUpRepo.signUp(nickname: nickname,
                                              imagePath: imagePath,
                                              socialAccountInfo: socialAccountInfo)
            }
    }
    
    private func uploadImage(_ data: Data?) -> Single<String> {
        return Single.deferred { [weak self] in
            guard let self else { return .error(AppError.unknownError) }
            guard let data else { return .just("")}
            
            return self.imageUploadRepo.uploadImage(image: data, path: .profile)
                .map { String(data: $0, encoding: .utf8) ?? "" }
                .do { print(#function, #line, "# 30 : \($0)" ) }
        }
    }
    
    #warning("허용범위 내로 수정하기")
    private func convertImageToData(_ image: UIImage?, quality: CGFloat = 0.1) -> Data? {
        return image?.jpegData(compressionQuality: quality)
    }
}

