//
//  ResponseDecoders.swift
//  Data
//
//  HTTP Response 디코더 구현체들
//

import Foundation

// MARK: - JSON Decoder
public class JSONResponseDecoder: ResponseDecoder {
    private let jsonDecoder = JSONDecoder()

    public init() {}

    public func decode<T: Decodable>(_ data: Data) throws -> T {
        return try jsonDecoder.decode(T.self, from: data)
    }
}

// MARK: - Raw Data Decoder (토큰 등 바이너리 응답용)
public class RawDataResponseDecoder: ResponseDecoder {

    public init() {}

    public enum CodingKeys: String, CodingKey {
        case `default` = ""
    }

    public func decode<T: Decodable>(_ data: Data) throws -> T {
        if T.self is Data.Type, let data = data as? T {
            return data
        } else {
            let context = DecodingError.Context(
                codingPath: [CodingKeys.default],
                debugDescription: "Expected Data type"
            )
            throw Swift.DecodingError.typeMismatch(T.self, context)
        }
    }
}
