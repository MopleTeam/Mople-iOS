//
//  EditProfile.swift
//  Group
//
//  Created by CatSlave on 10/14/24.
//

import Foundation
import RxSwift

protocol FetchProfile {
    func fetchProfile() -> Single<ProfileInfo>
}

