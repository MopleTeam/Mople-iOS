//
//  MeetMock.swift
//  Mople
//
//  Created by CatSlave on 1/7/25.
//

import Foundation

extension Meet {
    private static var randomDate: Date {
        Date().addingTimeInterval((3600 * Double(Int.random(in: -50...50))))
    }
    
    static func mock(id: Int) -> Self {
        return Meet(meetSummary: .mock(id: id),
                    sinceDays: Int.random(in: 1...100),
                    creatorId: 0,
                    memberCount: Int.random(in: 1...100),
                    firstPlanDate: randomDate)
    }
}

extension MeetSummary {
    static func mock(id: Int) -> MeetSummary {
        return .init(id: id,
                     name: "테스트 모임 \(id)",
                     imagePath: "https://picsum.photos/id/\(Int.random(in: 1...100))/200/300")
    }
}
