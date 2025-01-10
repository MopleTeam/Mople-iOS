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
        return Single.deferred { [weak self] in
            guard let self else { return .error(AppError.unknownError) }
            
            do {
                let imageData = try Data.imageDataCompressed(uiImage: image)
                return self.uploadImage(imageData)
                    .flatMap { self.profileEditRepo.editProfile(nickname: nickname,
                                                                imagePath: $0) }
            } catch {
                return .error(error)
            }
        }
    }
    
    private func uploadImage(_ data: Data?) -> Single<String?> {
        return Single.deferred { [weak self] in
            guard let self else { return .error(AppError.unknownError) }
            guard let data else { return .just(nil) }
            return self.imageUploadRepo.uploadImage(image: data, path: .profile)
        }
    }
}
