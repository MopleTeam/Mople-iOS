//
//  FetchGroupListMock.swift
//  Group
//
//  Created by CatSlave on 9/10/24.
//

import Foundation
import RxSwift

final class FetchGroupListMock: FetchMeetList {
    

    
    private var randomThumnail: String {
        return "https://picsum.photos/id/\(Int.random(in: 1...100))/200/300"
    }
    
    private func getMockData() -> [Meet] {
        
        var list = (1...5).map { index in
            Meet.mock(id: index, creatorId: index)
        }
        list.append(.mock(id: 103, creatorId: 103))
        return list
    }
    
    func execute() -> Single<[Meet]> {
        return Observable.just(getMockData())
            .delay(.milliseconds(300), scheduler: MainScheduler.instance)
            .asSingle()
    }
}



