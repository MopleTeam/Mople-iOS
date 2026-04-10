//
//  URL+Query.swift
//  Mople
//
//  Created by CatSlave on 4/24/25.
//

import Foundation

extension URL {
    var queryParameters: QueryParameters {
        return QueryParameters(url: self)
    }
}

class QueryParameters {
    let queryItems: [URLQueryItem]
    
    init(url: URL) {
        queryItems = URLComponents(string: url.absoluteString)?.queryItems ?? []
    }
    
    subscript(name: String) -> String? {
        return queryItems.first { $0.name == name }?.value
    }
}
