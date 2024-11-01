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

enum HTTPHeader {
    case accept
    case content
    case both
    
    var headers: [String: String] {
        switch self {
        case .accept:
            return ["Accept": "application/json"]
        case .content:
            return ["Content-Type": "application/json"]
        case .both:
            return ["Accept": "application/json",
                   "Content-Type": "application/json"]
        }
    }
}

struct APIEndpoints {
    
    private static func getAccessTokenParameters() throws -> [String:String] {
        guard let token = KeyChainService.cachedToken?.accessToken else { throw TokenError.noTokenError }
        return ["Authorization":"Bearer \(token)"]
    }
    
    private static func getRefreshTokenParameters() throws -> [String:String] {
        guard let token = KeyChainService.cachedToken?.refreshToken else { throw TokenError.noTokenError }
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
    static func executeLogin(platform: LoginPlatform, code: String) -> Endpoint<Data> {
        return Endpoint(path: "auth/sign-up",
                        method: .post,
                        headerParameters: HTTPHeader.both.headers,
                        bodyParameters: ["socialProvider": platform.rawValue,
                                         "providerToken": code,
                                         "deviceType": "IOS"],
                        responseDecoder: RawDataResponseDecoder())
    }
}

// MARK: - Profile
extension APIEndpoints {

    static func setupProfile(image: Data, nickName: String) throws -> Endpoint<Void> {
        let token = try getAccessTokenParameters()
        
        return Endpoint(path: "user/me",
                        method: .patch,
                        headerParameters: token,
                        bodyParameters: ["profileImg" : image, "nickname" : nickName])
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
