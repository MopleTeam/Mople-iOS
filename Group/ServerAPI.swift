//
//  ServerAPI.swift
//  Group
//
//  Created by CatSlave on 7/25/24.
//
// http://www.ugsm.co.kr:3000

import Foundation

//"accessToken": "string",
//  "refreshToken": "string"

struct TokenInfo: Codable {
    var accessToken: String?
    var refreshToken: String?
    
    enum CodingKeys: String, CodingKey {
        case accessToken
        case refreshToken
    }
}

struct UserInfo: Codable {
    let id: Int?
    let nickname: String?
    let profileImgURL: String?
    let badgeCount: Int?

    enum CodingKeys: String, CodingKey {
        case id, nickname
        case profileImgURL = "profileImgUrl"
        case badgeCount
    }
}

class ServerAPI {
    
    let projectID = ""
    let grantType = ""
    let clientSecret = ""
    let baseUrl: String = AppConfiguration().apiBaseURL
    // https://group.ugsm.co.kr
    static let shared = ServerAPI()
    
    private init() { }
    
    enum ApiError: Error {
        case notAllowUrl
        case unknownError(err: Error)
        case noContent
        case decodeError
        
        var info: String {
            switch self {
            case .noContent: "데이터가 없습니다."
            case .notAllowUrl: "잘못된 Url 입니다."
            case .decodeError: "디코딩 에러입니다."
            case .unknownError(_): "알 수 없는 에러입니다."
            }
        }
    }
    
    typealias ServerTest = Result<Void, ApiError>
    typealias LoginTest = Result<Data, ApiError>
    
    // http://www.ugsm.co.kr:3000/auth/apple/login?code=
    
    func apiTest(url: String,
                 authorizationCode: String,
                 completion: @escaping (ServerTest) -> Void) {
                
        let urlString = "\(url)?code=\(authorizationCode)"
        
        guard let serverUrl = URL(string: urlString) else {
            return completion(.failure(.notAllowUrl))
        }
        
        URLSession.shared.dataTask(with: serverUrl) { data, response, err in
            if let err = err {
                return completion(.failure(.unknownError(err: err)))
            }
            
            if let _ = data {
                return completion(.success(()))
            }
        }.resume()
    }
    
    func getUserInfo() {
        guard let accessToken = TokenKeyChain().getToken()?.accessToken else { return }
        
        let localUrl = "https://group.ugsm.co.kr/"
        
        let endpoint = localUrl.appending("user/me")
        
        guard let url = URL(string: endpoint) else { return }
        
        var urlRequest = URLRequest(url: url)
        
//        let authHeader: [String:String] = ["Authorization":accessToken]
        
//        urlRequest.allHTTPHeaderFields = authHeader
        
        urlRequest.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        print("url : \(endpoint), token: \(accessToken)")
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, err in
            if let err = err  {
                print("err : \(err.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else { return }
            print("heetpResponse : \(httpResponse.statusCode)")
            guard let data = data else { return }
            print("data 있음")
            guard let userInfo = try? JSONDecoder().decode(UserInfo.self, from: data) else { return }
            print(userInfo)
        }.resume()
    }
    
    func loginTest(authrizationCode: String, completion: @escaping ((LoginTest) -> Void)) {
        let loginServer = baseUrl + "/auth/apple/login?code=\(authrizationCode)"
        
        guard let serverUrl = URL(string: loginServer) else {
            print("session error")
            return completion(.failure(.notAllowUrl))
        }
        
        URLSession.shared.dataTask(with: serverUrl) { data, _, err in
            if let err = err {
                print("session error")
                return completion(.failure(.unknownError(err: err)))
            }
            
            guard let data = data else {
                print("session error")
                return completion(.failure(.noContent))
            }
            
            return completion(.success(data))
        }.resume()
    }
}

