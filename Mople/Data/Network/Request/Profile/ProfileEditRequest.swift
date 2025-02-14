//
//  ProfileEditRequest.swift
//  Mople
//
//  Created by CatSlave on 2/11/25.
//

import Foundation

struct ProfileEditRequest: Encodable {
    var image: String?
    var nickname: String?
}

extension ProfileEditRequest {
    init(profile: UserInfo) {
        self.image = profile.imagePath
        self.nickname = profile.name
    }
}
