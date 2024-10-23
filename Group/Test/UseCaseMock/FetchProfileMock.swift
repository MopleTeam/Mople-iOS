//
//  EditProfileMock.swift
//  Group
//
//  Created by CatSlave on 10/14/24.
//

import Foundation
import RxSwift

final class FetchProfileMock: FetchProfile {
    
    func fetchProfile() -> Single<ProfileInfo> {
        return Single.just(ProfileInfo(name: "테스트테스트", imagePath: "https://picsum.photos/id/\(Int.random(in: 1...100))/200/300"))
    }
}
