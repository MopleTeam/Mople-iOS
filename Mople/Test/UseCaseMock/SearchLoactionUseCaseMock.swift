//
//  RequestSearchPlaceMock.swift
//  Mople
//
//  Created by CatSlave on 12/23/24.
//

import Foundation
import RxSwift

final class SearchLoactionUseCaseMock: SearchLoaction {
    func requestSearchLocation(query: String) -> Single<SearchPlaceResult> {
        return Observable.just(())
            .delay(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { _ in
                SearchPlaceResult.mock()
            }
            .asSingle()
    }
}

extension SearchPlaceResult {
    fileprivate static func mock() -> Self {
        let mockResult = Array(0...15).map({ index in
            PlaceInfo.mock(id: index)
        })
        
        return .init(result: Bool.random() ? [] : mockResult,
                     page: 0,
                     isEnd: true)
    }
}


extension PlaceInfo {
    fileprivate static func mock(id: Int) -> Self {
        return .init(title: "CGV 청담씨네마시티 \(id)",
                     distance: 3000,
                     address: "테스트 Address",
                     roadAddress: "서울 강남구 도산대로 323 8층",
                     longitude: 126.963950815777,
                     latitude: 37.5297517407141)
    }
}
