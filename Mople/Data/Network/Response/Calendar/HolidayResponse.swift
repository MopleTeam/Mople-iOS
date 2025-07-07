//
//  HolidayResponse.swift
//  Mople
//
//  Created by CatSlave on 6/15/25.
//

import Foundation

struct HolidayResponse: Decodable {
    let title: String
    let date: String
}

extension HolidayResponse {
    func toDomain() -> Holiday {
        let convertDate = DateManager.simpleServerDateFormatter.date(from: date)
        return .init(title: title,
                     date: convertDate)
    }
}
