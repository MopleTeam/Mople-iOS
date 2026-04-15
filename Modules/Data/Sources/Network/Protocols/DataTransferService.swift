//
//  DataTransferService.swift
//  Data
//
//  네트워크 응답 데이터를 디코딩하는 서비스 프로토콜
//  구현체(DefaultDataTransferService)는 App 타겟에 위치
//

import Foundation

// MARK: - 프로토콜 정의
public protocol DataTransferService {
    func request<T: Decodable, E: ResponseRequestable>(
        with endpoint: E
    ) async throws -> T where E.Response == T

    func request<E: ResponseRequestable>(
        with endpoint: E
    ) async throws where E.Response == Void
}

public protocol DataTransferErrorResolver {
    func resolve(error: NetworkError) -> DataTransferError
}

public protocol ResponseDecoder {
    func decode<T: Decodable>(_ data: Data) throws -> T
}

public protocol DataTransferErrorLogger {
    func log(error: Error)
}
