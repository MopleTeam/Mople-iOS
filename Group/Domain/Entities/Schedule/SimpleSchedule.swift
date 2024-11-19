//
//  SimpleSchedule.swift
//  Group
//
//  Created by CatSlave on 11/7/24.
//

import Foundation

struct SimpleSchedule: Schedulable, Hashable, Equatable {
    let commonScheudle: CommonSchedule?
    let group: CommonGroup?
    let participantsCount: Int?
    let weatherInfo: WeatherInfo?
    
    static func < (lhs: SimpleSchedule, rhs: SimpleSchedule) -> Bool {
        guard let lhsDate = lhs.commonScheudle,
              let rhsDate = rhs.commonScheudle else { return false }
        
        return lhsDate < rhsDate
    }
}
