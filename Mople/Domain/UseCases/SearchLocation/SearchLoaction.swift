//
//  SearchLoaction.swift
//  Mople
//
//  Created by CatSlave on 12/22/24.
//

import RxSwift

protocol SearchLoactionUseCase {
    func requestSearchLocation(query: String) -> Single<Void>
}
