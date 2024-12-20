//
//  FetchGroupListMock.swift
//  Group
//
//  Created by CatSlave on 9/10/24.
//

import Foundation
import RxSwift

final class FetchGroupListMock: FetchGroup {
    
    private var randomDate: Date {
        Date().addingTimeInterval((3600 * Double(Int.random(in: -50...50))))
    }
    
    private var randomThumnail: String {
        return "https://picsum.photos/id/\(Int.random(in: 1...100))/200/300"
    }
    
    private func getMockData() -> [Meet] {
        
        return (1...5).map { index in
            
            return Meet(meetSummary: .mock(id: index),
                        sinceDays: Int.random(in: 1...100),
                        creatorId: 0,
                        memberCount: Int.random(in: 1...100),
                        firstPlanDate: randomDate)
        }
    }
    
    func fetchGroupList() -> RxSwift.Single<[Meet]> {
        return Single.just(getMockData())
    }
}
