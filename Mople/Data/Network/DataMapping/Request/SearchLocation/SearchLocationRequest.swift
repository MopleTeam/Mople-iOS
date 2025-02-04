//
//  SearchLocationReqeust.swift
//  Mople
//
//  Created by CatSlave on 1/9/25.
//

import Foundation

struct SearchLocationRequest: Encodable {
    let query: String
    var x: String? = nil
    var y: String? = nil
}

extension SearchLocationRequest {
    init(query: String,
         x: Double?,
         y: Double?) {
        
        self.query = query
        setLocation(x: x, y: y)
    }
    
    private mutating func setLocation(x: Double?, y: Double?) {
        guard let x, let y else { return }
        self.x = String(x)
        self.y = String(y)
    }
}
