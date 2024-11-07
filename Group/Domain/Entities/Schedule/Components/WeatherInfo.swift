//
//  WeatherInfo.swift
//  Group
//
//  Created by CatSlave on 11/6/24.
//

import Foundation

struct WeatherInfo: Hashable, Equatable {
    let imagePath: String?
    let temperature: Int?
    let pop: Double?
    
    init(imagePath: String? = nil,
         temperature: Int? = nil,
         pop: Double? = nil) {
        self.imagePath = imagePath
        self.temperature = temperature
        self.pop = pop
    }
}
