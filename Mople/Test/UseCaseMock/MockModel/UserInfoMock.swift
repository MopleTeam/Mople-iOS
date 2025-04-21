//
//  UserInfoMock.swift
//  Mople
//
//  Created by CatSlave on 1/7/25.
//

import Foundation

extension UserInfo {
    static func getUser() -> [UserInfo] {
        var members: [UserInfo] = []
        let num = Int.random(in: 1...10)
        for i in 1...num {
            members.append(.init(id: nil,
                                 notifyCount: 0,
                                 name: "User\(i)",
                                 imagePath: "https://picsum.photos/id/\(Int.random(in: 1...100))/200/300"))
        }
        
        return members
    }
}
