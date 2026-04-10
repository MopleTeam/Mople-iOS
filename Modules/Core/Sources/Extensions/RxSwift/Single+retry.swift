//
//  Single+retry.swift
//  Mople
//
//  Created by CatSlave on 12/4/24.
//

import RxSwift

extension Single {
    func retryWithDelayAndCondition(retryCount: Int = 1,
                                     delay: Int = 1,
                                     when: ((Error) -> Bool)? = nil
    ) -> Single<Element> {
        return self.asObservable()
            .retry { (observableErr: Observable<Error>) in
                observableErr
                    .flatMap { err in
                        guard (when?(err) ?? true) else { throw err }
                        return Observable<Void>.just(())
                            .delay(.seconds(delay), scheduler: MainScheduler.instance)
                    }
                    .take(retryCount)
            }
            .asSingle()
    }
}

