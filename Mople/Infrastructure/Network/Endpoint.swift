//
//  Endpoint.swift
//  Group
//
//  Created by CatSlave on 8/19/24.
//

import Foundation
import UIKit
import MultipartForm

enum HTTPMethodType: String {
    case get     = "GET"
    case head    = "HEAD"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
}

enum AuthenticationType {
    case none           // 인증 불필요
    case accessToken    // 액세스 토큰 인증
    case refreshToken   // 리프레시 토큰 인증
}

// Endpoint 생성 후 다른 곳으로 전달하며 사용하기에 class가 적합
class Endpoint<R>: ResponseRequestable {
    
    typealias Response = R
    
    let path: String
    let isFullPath: Bool
    let method: HTTPMethodType
    let headerParameters: [String: String]
    let queryParametersEncodable: Encodable?
    let queryParameters: [String: Any]
    let bodyParametersEncodable: Encodable?
    let bodyParameters: [String: Any]
    let bodyEncoder: BodyEncoder
    let responseDecoder: ResponseDecoder
    
    init(path: String,
         authenticationType: AuthenticationType = .none,
         isFullPath: Bool = false,
         method: HTTPMethodType,
         headerParameters: [String: String] = [:],
         queryParametersEncodable: Encodable? = nil,
         queryParameters: [String: Any] = [:],
         bodyParametersEncodable: Encodable? = nil,
         bodyParameters: [String: Any] = [:],
         bodyEncoder: BodyEncoder = JSONBodyEncoder(),
         responseDecoder: ResponseDecoder = JSONResponseDecoder()) throws {
        
        self.path = path
        self.isFullPath = isFullPath
        self.method = method
        self.headerParameters = try Self.applyAuthentication(to: headerParameters, type: authenticationType)
        self.queryParametersEncodable = queryParametersEncodable
        self.queryParameters = queryParameters
        self.bodyParametersEncodable = bodyParametersEncodable
        self.bodyParameters = bodyParameters
        self.bodyEncoder = bodyEncoder
        self.responseDecoder = responseDecoder
    }
}

extension Endpoint {
    static func applyAuthentication(to headers: [String:String], type: AuthenticationType) throws -> [String:String] {
        switch type {
        case .none:
            return headers
        case .accessToken:
            guard let token = KeyChainService.cachedToken?.accessToken else {
                throw AppError.expiredToken
            }
            let tokenHeader = ["Authorization":"Bearer \(token)"]
            return headers.merging(tokenHeader) { current, _ in current }
        case .refreshToken:
            guard let token = KeyChainService.cachedToken?.refreshToken else {
                throw AppError.expiredToken
            }
            let tokenHeader = ["Refresh":" \(token)"]
            return headers.merging(tokenHeader) { current, _ in current }
        }
    }
}

protocol BodyEncoder {
    func encode(_ parameters: [String: Any]) -> Data?
}

protocol Requestable {
    var path: String { get }
    var isFullPath: Bool { get }
    var method: HTTPMethodType { get }
    var headerParameters: [String: String] { get }
    var queryParametersEncodable: Encodable? { get }
    var queryParameters: [String: Any] { get }
    var bodyParametersEncodable: Encodable? { get }
    var bodyParameters: [String: Any] { get }
    var bodyEncoder: BodyEncoder { get }
    
    func urlRequest(with networkConfig: NetworkConfigurable) throws -> URLRequest
}

protocol ResponseRequestable: Requestable {
    associatedtype Response
    
    var responseDecoder: ResponseDecoder { get }
}

enum RequestGenerationError: Error {
    case components
    case notAllowUrl
}

extension Requestable {
    
    func url(with config: NetworkConfigurable) throws -> URL {
        
        guard let url = config.baseURL else { throw RequestGenerationError.notAllowUrl }

        let baseURL = url.absoluteString.last != "/"
        ? url.absoluteString + "/"
        : url.absoluteString
        
        let endpoint = isFullPath ? path : baseURL.appending(path)
        
        guard var urlComponents = URLComponents(string: endpoint) else {
            throw RequestGenerationError.components }
        
        var urlQueryItems = [URLQueryItem]()

        let queryParameters = try queryParametersEncodable?.toDictionary() ?? self.queryParameters
        
        queryParameters.forEach {
            urlQueryItems.append(URLQueryItem(name: $0.key, value: "\($0.value)"))
        }
        
        config.queryParameters.forEach {
            urlQueryItems.append(URLQueryItem(name: $0.key, value: $0.value))
        }
        urlComponents.queryItems = !urlQueryItems.isEmpty ? urlQueryItems : nil
        guard let url = urlComponents.url else { throw RequestGenerationError.components }
        
        return url
    }
    
    
    func urlRequest(with config: NetworkConfigurable) throws -> URLRequest {
        
        let url = try self.url(with: config)
        var urlRequest = URLRequest(url: url)
        var allHeaders: [String: String] = config.headers
        headerParameters.forEach { allHeaders.updateValue($1, forKey: $0) }
        
        let bodyParameters = try bodyParametersEncodable?.toDictionary() ?? self.bodyParameters
        
        if !bodyParameters.isEmpty {
            urlRequest.httpBody = bodyEncoder.encode(bodyParameters)
            print(#function, #line, "# 30 : \(urlRequest.httpBody)" )
        }
        
        urlRequest.httpMethod = method.rawValue
        
        urlRequest.allHTTPHeaderFields = allHeaders

        return urlRequest
    }
}

private extension Dictionary {
    var queryString: String {
        return self.map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
            .addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) ?? ""
    }
}

private extension Encodable {
    func toDictionary() throws -> [String: Any]? {
        let data = try JSONEncoder().encode(self)
        let jsonData = try JSONSerialization.jsonObject(with: data)
        return jsonData as? [String : Any]
    }
}

// MARK: - Encoder
struct JSONBodyEncoder: BodyEncoder {
    func encode(_ parameters: [String: Any]) -> Data? {
        return try? JSONSerialization.data(withJSONObject: parameters)
    }
}

struct MultipartBodyEncoder: BodyEncoder {
    var boundary: String
    
    func encode(_ parameters: [String : Any]) -> Data? {
 
        let parts = parameters.flatMap { (key, value) -> [MultipartForm.Part] in
               if checkCollection(value) {
                   guard let datas = value as? [Data] else { return [] }
                   return makeDataArrayPart((key, datas))
               } else {
                   guard let singlePart = makeSinglePart((key, value)) else { return [] }
                   return [singlePart]
               }
           }
        
        let form = MultipartForm(parts: parts, boundary: boundary)
        return form.bodyData
    }
    
    private func makeDataArrayPart(_ parameter: (key: String, value: [Data])) -> [MultipartForm.Part] {
        parameter.value.map {
            MultipartForm.Part(name: parameter.key,
                               data: $0,
                               filename: "Review",
                               contentType: "image/jpeg")
        }
    }
    
    private func makeSinglePart(_ parameter: (key: String, value: Any)) -> MultipartForm.Part? {
        switch parameter.value {
        case let value as Data:
            return .init(name: parameter.key,
                         data: value,
                         filename: "Profile",
                         contentType: "image/jpeg")
        case let value as String:
            return .init(name: parameter.key,
                         value: value)
        default:
            return nil
        }
    }
    
    private func checkCollection<T>(_ value: T) -> Bool {
        return value is Array<Any>
    }
}

// Use Test
struct AsciiBodyEncoder: BodyEncoder {
    func encode(_ parameters: [String: Any]) -> Data? {
        return parameters.queryString.data(using: String.Encoding.ascii, allowLossyConversion: true)
    }
}



