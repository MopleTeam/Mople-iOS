//
//  FetchGroupListMock.swift
//  Group
//
//  Created by CatSlave on 9/10/24.
//

import Foundation
import RxSwift

final class FetchGroupListMock: FetchMeetListUseCase {
    

    
    private var randomThumnail: String {
        return "https://picsum.photos/id/\(Int.random(in: 1...100))/200/300"
    }
    
    private func getMockData() -> [Meet] {
        
        return (1...5).map { index in
            
            return Meet.mock(id: index)
        }
    }
    
    func fetchGroupList() -> Single<[Meet]> {
        return Observable.just(getMockData())
            .delay(.milliseconds(300), scheduler: MainScheduler.instance)
            .asSingle()
    }
}

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

