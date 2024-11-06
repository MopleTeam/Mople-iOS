//
//  FetchGroupListMock.swift
//  Group
//
//  Created by CatSlave on 9/10/24.
//

import Foundation
import RxSwift

final class FetchGroupListMock: FetchGroup {
    
    private var randomThumnail: String {
        return "https://picsum.photos/id/\(Int.random(in: 1...100))/200/300"
    }
    
    
    
    private func getMockData() -> [Group] {
                
        return Array(1...5).map { index in
            Group(id: nil,
                  title: "모임\(index)",
                  members: UserInfo.getUser(),
                  thumbnailPath: randomThumnail,
                  createdDate: nil,
                  lastSchedule: nil)
        }
    }
    
    func fetchGroupList() -> RxSwift.Single<[Group]> {
        return Single.just(getMockData())
    }
    
    
}
