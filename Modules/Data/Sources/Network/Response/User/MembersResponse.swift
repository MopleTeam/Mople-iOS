//
//  MemberInfoResponse.swift
//  Mople
//
//  Created by CatSlave on 2/5/25.
//

import Foundation
import Domain

struct MemberInfoResponse: Decodable {
    let userId: Int?
    let nickname: String?
    let image: String?
    let role: String?
}

extension MemberInfoResponse {
    func toDomain() -> MemberInfo {
        return .init(memberId: userId,
                     nickname: nickname,
                     imagePath: image,
                     position: getPosition())
    }
    
    private func getPosition() -> MemberPositionType {
        switch role {
        case "HOST": .owner
        case "CREATOR": .host
        default: .member
        }
    }
}
