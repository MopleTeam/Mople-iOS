//
//  Weather.swift
//  Mople
//
//  Created by CatSlave on 12/10/24.
//

import Foundation

public struct Weather: Hashable {
    public let address: String?
    public let imagePath: String?
    public let temperature: Double?
    public let pop: Double?

    public init(address: String? = nil, imagePath: String? = nil, temperature: Double? = nil, pop: Double? = nil) {
        self.address = address
        self.imagePath = imagePath
        self.temperature = temperature
        self.pop = pop
    }
}
