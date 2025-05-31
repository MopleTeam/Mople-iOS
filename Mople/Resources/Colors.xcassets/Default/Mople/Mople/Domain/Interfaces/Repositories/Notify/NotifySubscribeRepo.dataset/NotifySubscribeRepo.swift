//
//  NotifySubscribe.swift
//  Mople
//
//  Created by CatSlave on 4/11/25.
//

import RxSwift

protocol NotifySubscribeRepo {
    func fetchNotifyState() -> Single<[String]>
    func subscribeNotify(type: SubscribeType,
                         isSubscribe: Bool) -> Single<Void>
}
