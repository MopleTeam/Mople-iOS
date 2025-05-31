//
//  DatesResponse.swift
//  Mople
//
//  Created by CatSlave on 2/24/25.
//

import Foundation

struct AllPlanDateResponse: Decodable {
    let dates: [String]
}

extension AllPlanDateResponse {
    func toDomain() -> AllPlanDate {
        let dateList = dates.compactMap { DateManager.simpleServerDateFormatter.date(from: $0) }
        return .init(dates: dateList)
    }
}
