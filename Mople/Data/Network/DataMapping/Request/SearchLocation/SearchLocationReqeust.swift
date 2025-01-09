//
//  SearchLocationReqeust.swift
//  Mople
//
//  Created by CatSlave on 1/9/25.
//

import Foundation

struct SearchLocationReqeust: Encodable {
    let query: String
    let x: String?
    let y: String?
}
