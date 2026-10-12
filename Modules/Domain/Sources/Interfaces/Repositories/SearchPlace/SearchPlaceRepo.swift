//
//  SearchLocationRepo.swift
//  Mople
//
//  Created by CatSlave on 1/9/25.
//

public protocol SearchPlaceRepo {
    func search(request: SearchLocationRequest) async throws -> SearchPlaceResult
}
