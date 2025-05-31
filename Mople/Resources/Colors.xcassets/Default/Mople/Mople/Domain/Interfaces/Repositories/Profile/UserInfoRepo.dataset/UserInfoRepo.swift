//
//  ProfileRepo.swift
//  Mople
//
//  Created by CatSlave on 1/6/25.
//
import Foundation
import RxSwift

protocol UserInfoRepo {
    func updateUserInfo() -> Single<Void>
    func editProfile(requestModel: ProfileEditRequest) -> Single<Void>
}

