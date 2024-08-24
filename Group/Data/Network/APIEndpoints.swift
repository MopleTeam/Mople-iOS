//
//  APIEndpoints.swift
//  Group
//
//  Created by CatSlave on 8/22/24.
//

import Foundation

enum TokenError: Error {
    case noTokenError
}

struct APIEndpoints {
    
    private static var token = TokenKeyChain.cachedToken
    
    private static var accessToken: String? {
        token?.accessToken
    }
    
    static func login(code: String) -> Endpoint<Data> {
        
        return Endpoint(path: "auth/apple/login",
                        method: .get,
                        queryParameters: ["code": code],
                        responseDecoder: RawDataResponseDecoder())
    }
    
    static func setupProfile(image: Data, nickName: String) throws -> Endpoint<Void> {
        guard let token = accessToken else { throw TokenError.noTokenError }
        
        return Endpoint(path: "user/me",
                        method: .patch,
                        headerParameters: ["Authorization":token],
                        bodyParameters: ["profileImg" : image, "nickName" : nickName],
                        bodyEncoder: MultipartFormEncoder())
    }
}
