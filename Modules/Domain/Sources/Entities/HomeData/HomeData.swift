//
//  HomeModel.swift
//  Mople
//
//  Created by CatSlave on 12/16/24.
//

import Foundation

public struct HomeData {
    public var plans: [Plan]
    public var hasMeet: Bool

    public init(plans: [Plan], hasMeet: Bool) {
        self.plans = plans
        self.hasMeet = hasMeet
    }
}
