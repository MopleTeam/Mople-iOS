//
//  PlaceMock.swift
//  Mople
//
//  Created by CatSlave on 1/7/25.
//

import Foundation

extension PlaceInfo {
    static func mock(id: Int) -> Self {
        return .init(title: "CGV 청담씨네마시티 \(id)",
                     distance: 3000,
                     address: "테스트 Address",
                     roadAddress: "서울 강남구 도산대로 323 8층",
                     longitude: 128.3727604,
                     latitude: 36.1200412)
    }
}

extension SearchPlaceResult {
    static func mock() -> Self {
        let mockResult = Array(0...15).map({ index in
            PlaceInfo.mock(id: index)
        })
        
        return .init(result: mockResult,
                     page: 0,
                     isEnd: true)
    }
}
