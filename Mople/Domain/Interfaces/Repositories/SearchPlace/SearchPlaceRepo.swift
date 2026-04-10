//
//  SearchLocationRepo.swift
//  Mople
//
//  Created by CatSlave on 1/9/25.
//

protocol SearchPlaceRepo {
    func search(request: SearchLocationRequest) async throws -> SearchPlaceResultResponse
}
