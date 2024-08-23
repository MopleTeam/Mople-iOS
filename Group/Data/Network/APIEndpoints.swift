//
//  APIEndpoints.swift
//  Group
//
//  Created by CatSlave on 8/22/24.
//

import Foundation

struct APIEndpoints {
    
    static func login(code: String) -> Endpoint<Data> {
        
        return Endpoint(path: "auth/apple/login",
                        method: .get,
                        queryParameters: ["code": code],
                        responseDecoder: RawDataResponseDecoder())
    }
    
}
