//
//  Weather.swift
//  Mople
//
//  Created by CatSlave on 12/10/24.
//

import Foundation

struct Weather: Hashable {
    let address: String?
    let imagePath: String?
    let temperature: Double?
    let pop: Double?
    
    var faceTemperature: Int {
        guard let temperature else { return 0 }
        let rounded = temperature.rounded()
        return Int(rounded)
    }
}
