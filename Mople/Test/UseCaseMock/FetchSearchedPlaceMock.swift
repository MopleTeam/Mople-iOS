//
//  FetchSearchedPlaceMock.swift
//  Mople
//
//  Created by CatSlave on 12/27/24.
//

import Foundation

final class SearchedPlaceStorageMock: SearchedPlaceStorage {
    private var cachedPlaces: [PlaceInfo] = []
    
    init() {
        self.fetchPlace()
    }
    
    func fetchPlace() {
        self.cachedPlaces = Array(0...3).map({ _ in
            PlaceInfo.mock()
        })
    }
    
    func readPlaces() -> [PlaceInfo] {
        return cachedPlaces
    }
    
    func addPlace(_ place: PlaceInfo) {
        
    }
    
    func deletePlace(_ place: PlaceInfo) {
        
    }
}

extension PlaceInfo {
    fileprivate static func mock() -> Self {
        return .init(title: "캐시 데이터",
                     distance: 3000,
                     address: "캐쉬 주소",
                     roadAddress: "캐쉬 도로명 주소",
                     longitude: 126.963950815777,
                     latitude: 37.5297517407141)
    }
}
