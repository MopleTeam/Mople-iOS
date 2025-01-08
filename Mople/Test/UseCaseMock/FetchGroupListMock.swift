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
        
        var list = (1...5).map { index in
            Meet.mock(id: index)
        }
        list.append(.mock(id: 103))
        return list
    }
    
    func fetchGroupList() -> Single<[Meet]> {
        return Observable.just(getMockData())
            .delay(.milliseconds(300), scheduler: MainScheduler.instance)
            .asSingle()
    }
}



