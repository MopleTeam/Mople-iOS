//
//  MemberInfoMock.swift
//  Mople
//
//  Created by CatSlave on 2/4/25.
//

import Foundation

extension PlanMemberList {
    static func mock() -> Self {
        let creatorId: Int = 1
        
        let randomNickname = [
            "Cool하늘45",
            "cool",
            "wonder맘123",
            "Sky다람77",
            "magic각자봄",
            "LIGHT갑순2",
            "Happy나래9",
            "DREAm미소",
            "7cloud라온",
            "98바다",
            "23sky소미",
            "1004자영",
            "777해님달",
            "365햇살",
            "9LUNA우주",
            "가진DongJu",
            "각진star21",
            "다솜BLUE55",
            "미르light1",
            "보름Sea912",
            "자연rain22",
            "하랑Wing3"
            ]
        
        let memberMock: [MemberInfo] = randomNickname.enumerated().map { index, name in
            return .mock(id: index, name: name)
            
        }
        
        let memberList = memberMock.map {
            var member = $0
            member.position = $0.memberId == creatorId ? .host : .member
            return member
        }
        
        return .init(creatorId: creatorId,
                     membsers: memberList)
    }
}

extension MemberInfo {
    static func mock(id: Int, name: String) -> Self {
        return .init(memberId: id,
                     nickname: name,
                     imagePath: "https://picsum.photos/id/\(id)/200/300")
    }
}
