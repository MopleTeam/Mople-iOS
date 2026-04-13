//
//  SignUpRepository.swift
//  Mople
//
//  Created by CatSlave on 11/28/24.
//

import Foundation

public protocol NicknameRepo {
    func creationNickname() async throws -> Data
    func isNicknameExists(_ name: String) async throws -> Data
}

