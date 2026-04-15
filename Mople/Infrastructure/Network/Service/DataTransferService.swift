//
//  DataTransferService.swift
//  Mople
//
//  Created by CatSlave on 8/19/24.
//  Refactored: RxSwift → async/await (Phase 3)
//  Data 모듈 분리: 프로토콜/에러/디코더 정의는 Data 모듈로 이전됨
//

import Foundation
import Domain
import Data

// MARK: - 구현체
final class DefaultDataTransferService {

    private let networkService: NetworkService
    private let errorResolver: DataTransferErrorResolver
    private let errorLogger: DataTransferErrorLogger

    init(
        with networkService: NetworkService,
        errorResolver: DataTransferErrorResolver = DefaultDataTransferErrorResolver(),
        errorLogger: DataTransferErrorLogger = DefaultDataTransferErrorLogger()
    ) {
        self.networkService = networkService
        self.errorResolver = errorResolver
        self.errorLogger = errorLogger
    }
}

extension DefaultDataTransferService: DataTransferService {

    /// 리턴값이 있는 요청
    func request<E: ResponseRequestable>(
        with endpoint: E
    ) async throws -> E.Response where E.Response: Decodable {
        do {
            let data = try await networkService.request(endpoint: endpoint)
            return try decode(data: data, decoder: endpoint.responseDecoder)
        } catch let error as NetworkError {
            throw errorResolver.resolve(error: error)
        } catch {
            throw error
        }
    }

    /// 응답만 있는 요청
    func request<E: ResponseRequestable>(
        with endpoint: E
    ) async throws where E.Response == Void {
        do {
            _ = try await networkService.request(endpoint: endpoint)
        } catch let error as NetworkError {
            throw errorResolver.resolve(error: error)
        } catch {
            throw error
        }
    }

    private func decode<T: Decodable>(data: Data?, decoder: ResponseDecoder) throws -> T {
        guard let data = data, !data.isEmpty else {
            throw DataTransferError.noResponse
        }

        do {
            let result: T = try decoder.decode(data)
            return result
        } catch {
            errorLogger.log(error: error)
            throw DataTransferError.parsing(error)
        }
    }
}

// MARK: - Logger
final class DefaultDataTransferErrorLogger: DataTransferErrorLogger {
    init() { }

    func log(error: Error) {
        printIfDebug("-------------")
        printIfDebug("\(error)")
    }
}

// MARK: - Error Resolver
class DefaultDataTransferErrorResolver: DataTransferErrorResolver {
    func resolve(error: NetworkError) -> DataTransferError {
        switch error {
        case let .error(statusCode, data):
            _ = try? JSONDecoder().decode(ErrorResponse.self, from: data)
            return handleErrorStatus(code: statusCode, err: error)
        default:
            return .networkFailure(error)
        }
    }

    private func handleErrorStatus(code: Int, err: Error) -> DataTransferError {
        switch code {
        case 400: .badRequest
        case 401: .expiredToken
        case 403: .noResponse
        case 404: .noResponse
        default : .unknownError(err)
        }
    }
}
