//
//  RequestLeavePlan.swift
//  Mople
//
//  Created by CatSlave on 1/7/25.
//

import RxSwift

protocol RequestLeavePlan {
    func requstLeavePlan(planId: Int) -> Single<Void>
}
