//
//  Holidays.swift
//  Mople
//
//  Created by CatSlave on 6/15/25.
//

import Foundation

public struct Holiday {
    public let title: String
    public let date: Date?

    public init(title: String, date: Date? = nil) {
        self.title = title
        self.date = date
    }
}


