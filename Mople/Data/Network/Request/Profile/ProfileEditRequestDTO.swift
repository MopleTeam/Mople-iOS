//
//  ProfileEditRequestDTO.swift
//  Mople
//
//  Created by CatSlave on 2/11/25.
//

import Foundation
import Domain

// MARK: - 프로필 수정 API 요청 DTO
struct ProfileEditRequestDTO: Encodable {
    var image: String?
    var nickname: String?
}

extension ProfileEditRequestDTO {
    init(profile: UserInfo) {
        self.image = profile.imagePath
        self.nickname = profile.name
    }

    init(request: ProfileEditRequest) {
        self.image = request.image
        self.nickname = request.nickname
    }
}
