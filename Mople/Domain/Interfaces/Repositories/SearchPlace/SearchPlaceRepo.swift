//
//  SearchLocationRepo.swift
//  Mople
//
//  Created by CatSlave on 1/9/25.
//

import RxSwift

protocol SearchPlaceRepo {
    func search(request: SearchLocationRequest) -> Single<SearchPlaceResultResponse>
}
