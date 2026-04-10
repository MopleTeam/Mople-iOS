//
//  SearchLoaction.swift
//  Mople
//
//  Created by CatSlave on 12/22/24.
//

import Foundation

protocol SearchPlace {
    func execute(query: String,
                 x: Double?,
                 y: Double?) async throws -> SearchPlaceResult
}

final class SearchPlaceUseCase: SearchPlace {

    private let searchPlaceRepo: SearchPlaceRepo

    init(searchPlaceRepo: SearchPlaceRepo) {
        self.searchPlaceRepo = searchPlaceRepo
    }

    func execute(query: String,
                 x: Double?,
                 y: Double?) async throws -> SearchPlaceResult {
        return try await searchPlaceRepo
            .search(request: .init(query: query, x: x, y: y))
    }
}

// MARK: - Mock
#if DEV
final class MockSearchPlaceUseCase: SearchPlace {
    func execute(query: String,
                 x: Double?,
                 y: Double?) async throws -> SearchPlaceResult {
        print("✅ [Mock] 장소 검색 - query: \(query), x: \(x ?? 0), y: \(y ?? 0)")

        let mockPlaces: [PlaceInfo] = [
            PlaceInfo(uuid: UUID().uuidString,
                      title: "\(query) 카페",
                      distance: 350,
                      address: "서울특별시 강남구 역삼동 123-45",
                      roadAddress: "서울특별시 강남구 테헤란로 123",
                      location: Location(longitude: 127.0276, latitude: 37.4979)),
            PlaceInfo(uuid: UUID().uuidString,
                      title: "\(query) 레스토랑",
                      distance: 800,
                      address: "서울특별시 서초구 서초동 678-90",
                      roadAddress: "서울특별시 서초구 서초대로 456",
                      location: Location(longitude: 127.0246, latitude: 37.4919)),
            PlaceInfo(uuid: UUID().uuidString,
                      title: "\(query) 공원",
                      distance: 1200,
                      address: "서울특별시 송파구 잠실동 111-22",
                      roadAddress: "서울특별시 송파구 올림픽로 789",
                      location: Location(longitude: 127.0716, latitude: 37.5133))
        ]

        let result = SearchPlaceResult(places: mockPlaces,
                                       page: 1,
                                       isEnd: true)

        try await Task.sleep(nanoseconds: 1_000_000_000)
        return result
    }
}
#endif
