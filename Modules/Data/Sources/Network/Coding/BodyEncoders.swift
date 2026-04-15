//
//  BodyEncoders.swift
//  Data
//
//  HTTP Body 인코더 구현체들
//

import Foundation
import MultipartForm

// MARK: - JSON Encoder
public struct JSONBodyEncoder: BodyEncoder {
    public init() {}

    public func encode(_ parameters: [String: Any]) -> Data? {
        return try? JSONSerialization.data(withJSONObject: parameters)
    }
}

// MARK: - Multipart Encoder (이미지 업로드용)
public struct MultipartBodyEncoder: BodyEncoder {
    public var boundary: String

    public init(boundary: String) {
        self.boundary = boundary
    }

    public func encode(_ parameters: [String: Any]) -> Data? {
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

    private func getImageInfo(from data: Data) -> (extension: String, mimeType: String) {
        guard data.count > 4 else { return ("jpg", "image/jpeg") }

        let bytes = data.prefix(4)
        if bytes.starts(with: [0xFF, 0xD8, 0xFF]) {
            return ("jpg", "image/jpeg")
        } else if bytes.starts(with: [0x89, 0x50, 0x4E, 0x47]) {
            return ("png", "image/png")
        } else if bytes.starts(with: [0x47, 0x49, 0x46]) {
            return ("gif", "image/gif")
        }
        return ("jpg", "image/jpeg")
    }

    private func makeDataArrayPart(_ parameter: (key: String, value: [Data])) -> [MultipartForm.Part] {
        parameter.value.map {
            let imageInfo = getImageInfo(from: $0)
            return MultipartForm.Part(name: parameter.key,
                                      data: $0,
                                      filename: "Photo.\(imageInfo.extension)",
                                      contentType: imageInfo.mimeType)
        }
    }

    private func makeSinglePart(_ parameter: (key: String, value: Any)) -> MultipartForm.Part? {
        switch parameter.value {
        case let value as Data:
            let imageInfo = getImageInfo(from: value)
            return .init(name: parameter.key,
                         data: value,
                         filename: "Photo.\(imageInfo.extension)",
                         contentType: imageInfo.mimeType)
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

// MARK: - ASCII Encoder (테스트용)
public struct AsciiBodyEncoder: BodyEncoder {
    public init() {}

    public func encode(_ parameters: [String: Any]) -> Data? {
        return parameters.map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
            .addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)?
            .data(using: .ascii, allowLossyConversion: true)
    }
}
