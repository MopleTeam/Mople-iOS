//
//  NetworkError.swift
//  Data
//
//  네트워크 레이어 에러 정의
//

import Foundation

/// URLSession 레벨 네트워크 에러
public enum NetworkError: Error {
    case notConnectedInternet
    case notConnectedServer
    case unknownError(Error?)
    case urlGeneration
    case error(statusCode: Int, data: Data)
}

/// DataTransferService 레벨 에러
public enum DataTransferError: Error {
    case parsing(Error)
    case networkFailure(NetworkError)
    case expiredToken
    case noResponse
    case unknownError(Error)
    case badRequest
}
