//
//  EditProfile.swift
//  Group
//
//  Created by CatSlave on 10/14/24.
//

import Foundation
import RxSwift

protocol EditProfile {
    
    func fetchProfile() -> Single<ProfileInfo>
    func logoutAccount() -> Single<Void>
    func deleteAccount() -> Single<Void>
}
