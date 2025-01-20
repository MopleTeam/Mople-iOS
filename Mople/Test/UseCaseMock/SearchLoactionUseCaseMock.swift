//
//  RequestSearchPlaceMock.swift
//  Mople
//
//  Created by CatSlave on 12/23/24.
//

import Foundation
import RxSwift

final class SearchLoactionUseCaseMock: SearchPlace {
    func executu(query: String, x: Double?, y: Double?) -> RxSwift.Single<SearchPlaceResult> {
        return Observable.just(())
            .delay(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { _ in
                SearchPlaceResult.mock()
            }
            .asSingle()
    }
}


