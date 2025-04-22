//
//  NotifyRespository.swift
//  Mople
//
//  Created by CatSlave on 4/10/25.
//

import RxSwift

protocol NotifyRepo {
    func fetchNotifyList() -> Single<[NotifyResponse]>
    func resetNotifyCount() -> Single<Void>
}
