//
//  SearchLocationRequestDTO.swift
//  Mople
//
//  Created by CatSlave on 1/9/25.
//

import Foundation
import Domain

struct SearchLocationRequestDTO: Encodable {
    let query: String
    var x: String? = nil
    var y: String? = nil
}

extension SearchLocationRequestDTO {
    init(request: SearchLocationRequest) {
        self.query = request.query
        if let x = request.x, let y = request.y {
            self.x = String(x)
            self.y = String(y)
        }
    }
}
