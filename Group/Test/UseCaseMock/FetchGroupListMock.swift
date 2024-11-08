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
    
    private func getMockData() -> [SimpleGroup] {
        
        var groupArray: [SimpleGroup] = []

        let randomGroup = (1...6).map { index in
            if index <= 5 {
                return SimpleGroup(
                    commonGroup: .getGroup(name: "\(index)"),
                    memberCount: Int.random(in: 5...50),
                    lastScheduleDate: randomDate
                )
            } else {
                return SimpleGroup(
                    commonGroup: .getGroup(name: "6"),
                    memberCount: 20,
                    lastScheduleDate: nil
                )
            }
        }

        groupArray.append(contentsOf: randomGroup)
        return groupArray
    }
    
    func fetchGroupList() -> RxSwift.Single<[SimpleGroup]> {
        return Single.just(getMockData())
    }
    
    
}
