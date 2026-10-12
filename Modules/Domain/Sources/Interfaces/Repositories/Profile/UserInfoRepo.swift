//
//  ProfileRepo.swift
//  Mople
//
//  Created by CatSlave on 1/6/25.
//
import Foundation

public protocol UserInfoRepo {
    func updateUserInfo() async throws
    func editProfile(requestModel: ProfileEditRequest) async throws
}

