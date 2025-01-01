//
//  SearchLoaction.swift
//  Mople
//
//  Created by CatSlave on 12/22/24.
//

import RxSwift

protocol SearchLoaction {
    func requestSearchLocation(query: String) -> Single<SearchPlaceResult>
}
