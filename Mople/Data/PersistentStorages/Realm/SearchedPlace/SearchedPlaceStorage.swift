//
//  SearchPlaceQueriesStorage.swift
//  Mople
//
//  Created by CatSlave on 12/27/24.
//

import Foundation
import RealmSwift

protocol SearchedPlaceStorage {
    func fetchPlace()
    func readPlaces() -> [PlaceInfo]
    func addPlace(_ place: PlaceInfo)
    func deletePlace(_ place: PlaceInfo)
}

final class DefaultSearchedPlaceStorage: SearchedPlaceStorage {
    
    private var cachedPlaces: [PlaceInfo] = []
    
    private let realmDB = try! Realm()
    
    private var queriesData: Results<PlaceInfoEntity> {
        return realmDB.objects(PlaceInfoEntity.self)
    }
    
    init() {
        self.fetchPlace()
    }
    
    func fetchPlace() {
        let sortEntities = queriesData.sorted(byKeyPath: "searchDate", ascending: false)
        self.cachedPlaces = sortEntities.map { $0.toDomain() }
    }
    
    func readPlaces() -> [PlaceInfo] {
        return self.cachedPlaces
    }
    
    func addPlace(_ place: PlaceInfo) {
        deleteIfExists(place)
        addEntity(.init(place))
        fetchPlace()
    }
    
    func deletePlace(_ place: PlaceInfo) {
        guard let foundPlace = self.findPlaceByUUid(place) else { return }
        deleteEnitity(foundPlace)
        fetchPlace()
    }
}

// MARK: - Storage 상태관리
extension DefaultSearchedPlaceStorage {
    private func addEntity(_ place: PlaceInfoEntity) {
        try! realmDB.write({
            realmDB.add(place)
        })
    }
    
    private func deleteEnitity(_ place: PlaceInfoEntity) {
        try! realmDB.write({
            realmDB.delete(place)
        })
    }
}

// MARK: - Helper
extension DefaultSearchedPlaceStorage {
    
    /// 저장소에 있는 경우에만 삭제
    private func deleteIfExists(_ place: PlaceInfo) {
        if let foundPlace = self.findPlaceByInfo(place) {
            self.deleteEnitity(foundPlace)
        }
    }
}

// MARK: - Find
extension DefaultSearchedPlaceStorage {
    
    /// 서버로부터 받은 장소검색 결과의 제목과 좌표가 일치하는 저장 데이터 파싱
    /// 비교 데이터가 새로운 데이터이기에 UUID가 없음
    private func findPlaceByInfo(_ placeInfo: PlaceInfo) -> PlaceInfoEntity? {
        return queriesData.filter {
            $0.title == placeInfo.title &&
            $0.longitude == placeInfo.location?.longitude &&
            $0.latitude == placeInfo.location?.latitude
        }.first
    }
    
    /// 선택된 데이터와 기존 데이터의 UUID 일치하는 데이터 파싱
    private func findPlaceByUUid(_ place: PlaceInfo) -> PlaceInfoEntity? {
        guard let uuid = place.uuid else { return nil }
        return queriesData.filter { $0.id == uuid }.first
    }
}


