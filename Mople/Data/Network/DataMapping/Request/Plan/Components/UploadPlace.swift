//
//  UploadLocation.swift
//  Mople
//
//  Created by CatSlave on 12/17/24.
//

import Foundation

struct UploadPlace: Encodable {
    let title: String
    let planAddress: String
    let lat: Double
    let lot: Double
    let weatherAddress: String
}
