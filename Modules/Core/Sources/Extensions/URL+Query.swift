//
//  URL+Query.swift
//  Mople
//
//  Created by CatSlave on 4/24/25.
//

import Foundation

public extension URL {
    var queryParameters: QueryParameters {
        return QueryParameters(url: self)
    }
}

public class QueryParameters {
    public let queryItems: [URLQueryItem]

    public init(url: URL) {
        queryItems = URLComponents(string: url.absoluteString)?.queryItems ?? []
    }
    
    public subscript(name: String) -> String? {
        return queryItems.first { $0.name == name }?.value
    }
}
