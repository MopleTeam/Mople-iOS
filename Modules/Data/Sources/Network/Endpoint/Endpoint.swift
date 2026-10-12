//
//  Endpoint.swift
//  Data
//
//  API 엔드포인트 정의를 위한 타입들
//  Endpoint<R>: 제네릭 엔드포인트 + 인증/인코딩/디코딩 설정
//

import Foundation
import MultipartForm

// MARK: - HTTP 메서드
public enum HTTPMethodType: String {
    case get     = "GET"
    case head    = "HEAD"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
}

// MARK: - 인증 유형
public enum AuthenticationType {
    case none           // 인증 불필요
    case accessToken    // 액세스 토큰 인증
    case refreshToken   // 리프레시 토큰 인증
}

// MARK: - 토큰 제공 프로토콜 (KeychainStorage 의존 제거)
/// Endpoint가 인증 헤더를 구성할 때 사용하는 프로토콜
/// App 타겟의 KeychainStorage가 구현
public protocol TokenStorageProvider {
    var accessToken: String? { get }
    var refreshToken: String? { get }
}

// MARK: - Endpoint 클래스
/// Endpoint 생성 후 다른 곳으로 전달하며 사용하기에 class가 적합
public class Endpoint<R>: ResponseRequestable {

    public typealias Response = R

    public let path: String
    public let isFullPath: Bool
    public let method: HTTPMethodType
    public let headerParameters: [String: String]
    public let queryParametersEncodable: Encodable?
    public let queryParameters: [String: Any]
    public let bodyParametersEncodable: Encodable?
    public let bodyParameters: [String: Any]
    public let bodyEncoder: BodyEncoder
    public let responseDecoder: ResponseDecoder

    public init(path: String,
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
    /// 인증 헤더 적용 — TokenStorageProvider를 통해 토큰을 가져옴
    public static func applyAuthentication(to headers: [String: String], type: AuthenticationType) throws -> [String: String] {
        switch type {
        case .none:
            return headers
        case .accessToken:
            guard let token = EndpointTokenStorage.shared.provider?.accessToken else {
                throw DataRequestError.expiredToken
            }
            let tokenHeader = ["Authorization": "Bearer \(token)"]
            return headers.merging(tokenHeader) { current, _ in current }
        case .refreshToken:
            guard let token = EndpointTokenStorage.shared.provider?.refreshToken else {
                throw DataRequestError.expiredToken
            }
            let tokenHeader = ["Refresh": " \(token)"]
            return headers.merging(tokenHeader) { current, _ in current }
        }
    }
}

/// TokenStorageProvider를 전역으로 주입받는 싱글톤
/// App 시작 시 KeychainStorage를 등록
public final class EndpointTokenStorage {
    public static let shared = EndpointTokenStorage()
    public var provider: TokenStorageProvider?
    private init() {}
}

// MARK: - Requestable 프로토콜
public protocol BodyEncoder {
    func encode(_ parameters: [String: Any]) -> Data?
}

public protocol Requestable {
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

public protocol ResponseRequestable: Requestable {
    associatedtype Response

    var responseDecoder: ResponseDecoder { get }
}

public enum RequestGenerationError: Error {
    case components
    case notAllowUrl
}

extension Requestable {

    public func url(with config: NetworkConfigurable) throws -> URL {

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


    public func urlRequest(with config: NetworkConfigurable) throws -> URLRequest {

        let url = try self.url(with: config)
        var urlRequest = URLRequest(url: url)
        var allHeaders: [String: String] = config.headers
        headerParameters.forEach { allHeaders.updateValue($1, forKey: $0) }

        let bodyParameters = try bodyParametersEncodable?.toDictionary() ?? self.bodyParameters

        if !bodyParameters.isEmpty {
            urlRequest.httpBody = bodyEncoder.encode(bodyParameters)
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
        return jsonData as? [String: Any]
    }
}
