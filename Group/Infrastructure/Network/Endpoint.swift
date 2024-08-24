//
//  Endpoint.swift
//  Group
//
//  Created by CatSlave on 8/19/24.
//

import Foundation

enum HTTPMethodType: String {
    case get     = "GET"
    case head    = "HEAD"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
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
         isFullPath: Bool = false,
         method: HTTPMethodType,
         headerParameters: [String: String] = [:],
         queryParametersEncodable: Encodable? = nil,
         queryParameters: [String: Any] = [:],
         bodyParametersEncodable: Encodable? = nil,
         bodyParameters: [String: Any] = [:],
         bodyEncoder: BodyEncoder = JSONBodyEncoder(),
         responseDecoder: ResponseDecoder = JSONResponseDecoder()) {
        self.path = path
        self.isFullPath = isFullPath
        self.method = method
        self.headerParameters = headerParameters
        self.queryParametersEncodable = queryParametersEncodable
        self.queryParameters = queryParameters
        self.bodyParametersEncodable = bodyParametersEncodable
        self.bodyParameters = bodyParameters
        self.bodyEncoder = bodyEncoder
        self.responseDecoder = responseDecoder
    }
}

protocol BodyEncoder {
    func encode(_ parameters: [String: Any]) -> Data?
}

struct JSONBodyEncoder: BodyEncoder {
    func encode(_ parameters: [String: Any]) -> Data? {
        return try? JSONSerialization.data(withJSONObject: parameters)
    }
}

// Use Test
struct AsciiBodyEncoder: BodyEncoder {
    func encode(_ parameters: [String: Any]) -> Data? {
        return parameters.queryString.data(using: String.Encoding.ascii, allowLossyConversion: true)
    }
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
            
            if let multipartFormEncoder = bodyEncoder as? MultipartFormEncoder {
                urlRequest.addValue(multipartFormEncoder.contentType, forHTTPHeaderField: "Content-Type")
                urlRequest.httpBody = multipartFormEncoder.encode(bodyParameters)
            } else {
                urlRequest.httpBody = bodyEncoder.encode(bodyParameters)
            }
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



struct MultipartFormEncoder: Hashable, Equatable, BodyEncoder {
    public struct Part: Hashable, Equatable {
        public var name: String
        public var data: Data
        public var filename: String?
        public var contentType: String?
        
        public var value: String? {
            get {
                return String(bytes: self.data, encoding: .utf8)
            }
            set {
                guard let value = newValue else {
                    self.data = Data()
                    return
                }
                
                self.data = value.data(using: .utf8, allowLossyConversion: true)!
            }
        }
        
        public init(name: String, data: Data, filename: String? = nil, contentType: String? = nil) {
            self.name = name
            self.data = data
            self.filename = filename
            self.contentType = contentType
        }
        
        public init(name: String, value: String) {
            let data = value.data(using: .utf8, allowLossyConversion: true)!
            self.init(name: name, data: data, filename: nil, contentType: nil)
        }
    }
    
    public var boundary: String
    public var parts: [Part]
    
    public var contentType: String {
        return "multipart/form-data; boundary=\(self.boundary)"
    }
    
    func encode(_ parameters: [String : Any]) -> Data? {
        var body = Data()
        for part in self.parts {
            body.append("--\(self.boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(part.name)\"")
            if let filename = part.filename?.replacingOccurrences(of: "\"", with: "_") {
                body.append("; filename=\"\(filename)\"")
            }
            body.append("\r\n")
            if let contentType = part.contentType {
                body.append("Content-Type: \(contentType)\r\n")
            }
            body.append("\r\n")
            body.append(part.data)
            body.append("\r\n")
        }
        body.append("--\(self.boundary)--\r\n")
        
        return body
    }
    
    public init(parts: [Part] = [], boundary: String = UUID().uuidString) {
        self.parts = parts
        self.boundary = boundary
    }
    
    public subscript(name: String) -> Part? {
        get {
            return self.parts.first(where: { $0.name == name })
        }
        set {
            precondition(newValue == nil || newValue?.name == name)
            
            var parts = self.parts
            parts = parts.filter { $0.name != name }
            if let newValue = newValue {
                parts.append(newValue)
            }
            self.parts = parts
        }
    }
}

extension Data {
    mutating func append(_ string: String) {
        self.append(string.data(using: .utf8, allowLossyConversion: true)!)
    }
}
