//
//  FetchGroupListMock.swift
//  Group
//
//  Created by CatSlave on 9/10/24.
//

import Foundation
import RxSwift

final class FetchGroupListMock: FetchGroupList {
    
    private var randomThumnail: String {
        return "https://picsum.photos/id/\(Int.random(in: 1...100))/200/300"
    }
    
    
    
    private func getMockData() -> [Group] {
                
        return Array(1...5).map { index in
            Group(thumbnailPath: randomThumnail,
                  name: "모임\(index)",
                  memberCount: Int.random(in: 1...50),
                  lastSchedule: Date().addingTimeInterval(-3600*(24 * Double(index))))
        }
    }
    
    func fetchGroupList() -> RxSwift.Single<[Group]> {
        return Single.just(getMockData())
    }
    
    
}
