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
    
    private static func getAccessTokenParameters() throws -> [String:String] {
        guard let token = KeyChainServiceImpl.cachedToken?.accessToken else { throw TokenError.noTokenError }
        return ["Authorization":"Bearer \(token)"]
    }
    
    private static func getRefreshTokenParameters() throws -> [String:String] {
        guard let token = KeyChainServiceImpl.cachedToken?.refreshToken else { throw TokenError.noTokenError }
        return ["refreshToken": token]
    }
}

// MARK: - Token Refresh
extension APIEndpoints {
    static func reissueToken() throws -> Endpoint<String> {
        let (authHeader, refreshParameters) = try (getAccessTokenParameters(),
                                                   getRefreshTokenParameters())
        
        let headerParameters = ["Content-Type":"application/json"].merging(authHeader) { current, _ in current }
        
        return Endpoint(path: "auth/access-token",
                        method: .post,
                        headerParameters: headerParameters,
                        bodyParameters: refreshParameters)
    }
}

// MARK: - Login
extension APIEndpoints {
    static func login(code: String) -> Endpoint<Data> {
        
        return Endpoint(path: "auth/sign-up",
                        method: .get,
                        bodyParameters: ["socialProvider": "APPLE",
                                         "providerToken": code,
                                         "deviceType": "IOS"])
    }
}


// MARK: - Profile
extension APIEndpoints {

    static func setupProfile(image: Data, nickName: String) throws -> Endpoint<Void> {
        let token = try getAccessTokenParameters()
        
        return Endpoint(path: "user/me",
                        method: .patch,
                        headerParameters: token,
                        bodyParameters: ["profileImg" : image, "nickname" : nickName],
                        bodyEncoder: MultipartFormEncoder())
    }
    
    static func checkNickname(name: String) throws -> Endpoint<Bool> {
        let token = try getAccessTokenParameters()
        
        return Endpoint(path: "user/nickname/\(name)/duplicated",
                        method: .get,
                        headerParameters: token)
    }
    
    static func getRandomNickname() throws -> Endpoint<Data> {
        let token = try getAccessTokenParameters()
        
        return Endpoint(path: "user/nickname/random",
                        method: .get,
                        headerParameters: token,
                        responseDecoder: RawDataResponseDecoder())
    }
}
