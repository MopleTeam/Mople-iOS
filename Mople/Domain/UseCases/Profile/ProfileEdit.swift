//
//  ProfileEditUseCase.swift
//  Mople
//
//  Created by CatSlave on 11/28/24.
//

import UIKit
import RxSwift

protocol ProfileEdit {
    func editProfile(nickname: String, image: UIImage?) -> Single<Void>
}


final class ProfileEditUseCase: ProfileEdit {
    
    let imageUploadRepo: ImageUploadRepo
    let profileEditRepo: ProfileEditRepo
    
    init(imageUploadRepo: ImageUploadRepo,
         profileEditRepo: ProfileEditRepo) {
        self.imageUploadRepo = imageUploadRepo
        self.profileEditRepo = profileEditRepo
    }
}

// MARK: - Profile Edit
extension ProfileEditUseCase {
    func editProfile(nickname: String,
                     image: UIImage?) -> Single<Void> {
        
        let imageData = self.convertImageToData(image)
        return self.uploadImage(imageData)
            .map { $0.isEmpty ? nil : $0 }
            .flatMap { self.profileEditRepo.editProfile(nickname: nickname,
                                                        imagePath: $0) }
    }
    
    private func uploadImage(_ data: Data?) -> Single<String> {
        return Single.deferred {
            guard let data else {
                return .just("")
            }
            return self.imageUploadRepo.uploadImage(image: data, path: .profile)
                .map { String(data: $0, encoding: .utf8) ?? "" }
        }
    }
    
    private func convertImageToData(_ image: UIImage?, quality: CGFloat = 0.3) -> Data? {
        return image?.jpegData(compressionQuality: quality)
    }
}
