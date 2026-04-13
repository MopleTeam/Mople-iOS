//
//  UserRepository.swift
//  Group
//
//  Created by CatSlave on 8/22/24.
//
import Foundation

public protocol AuthenticationRepo {
    func signIn(social: SocialInfo) async throws
    func signUp(requestModel: SignUpRequest) async throws
    func signOut(userId: Int) async throws
    func deleteAccount() async throws
}



