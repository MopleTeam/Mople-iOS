//
//  RequestSearchPlaceMock.swift
//  Mople
//
//  Created by CatSlave on 12/23/24.
//

import Foundation
import RxSwift

final class SearchLoactionUseCaseMock: SearchLoaction {
    func requestSearchLocation(query: String, x: Double?, y: Double?) -> RxSwift.Single<SearchPlaceResult> {
        print(#function, #line, "query : \(query), x : \(x), y : \(y)")
        return Observable.just(())
            .delay(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { _ in
                SearchPlaceResult.mock()
            }
            .asSingle()
    }
}


