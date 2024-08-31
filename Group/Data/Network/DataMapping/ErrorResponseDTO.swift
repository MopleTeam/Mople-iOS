//
//  ErrorResponse.swift
//  Group
//
//  Created by CatSlave on 8/29/24.
//

import Foundation

struct ErrorResponse: Decodable {
    let code: Int?
    let data: Data?
    let message: String?
}
