//
//  SearchLocationRepo.swift
//  Mople
//
//  Created by CatSlave on 1/9/25.
//

import RxSwift

protocol SearchLocationRepo {
    func searchLocation(_ locationRequset: SearchLocationReqeust) -> Single<SearchPlaceResultResponse>
}
