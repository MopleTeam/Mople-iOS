//
//  ErrorResponse.swift
//  Group
//
//  Created by CatSlave on 8/29/24.
//

import Foundation
import Domain

public struct ErrorResponse: Decodable {
    public let code: String?
    public let message: String?
    public let data: Data?

    public init(code: String? = nil, message: String? = nil, data: Data? = nil) {
        self.code = code
        self.message = message
        self.data = data
    }
}
