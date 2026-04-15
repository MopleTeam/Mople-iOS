//
//  KeyChainManager.swift
//  Group
//
//  Created by CatSlave on 7/26/24.
//

import Foundation
import Domain
import Security

public final class KeychainStorage {

    public static let shared = KeychainStorage()

    private init() {}

    private(set) static var cachedToken: Token?

    enum Key: String {
        case service = "com.moim.moimtable"
        case token = "userToken"
        case email = "email"
    }
}

// MARK: - TokenStorageProvider 채택
/// Endpoint가 인증 헤더를 구성할 때 사용하는 토큰 제공자
extension KeychainStorage: TokenStorageProvider {
    public var accessToken: String? { getToken()?.accessToken }
    public var refreshToken: String? { getToken()?.refreshToken }
}

// MARK: - Apple Email 관리
extension KeychainStorage {
    public func saveEmail(_ email: String) {
        guard let emailData = email.data(using: .utf8) else { return }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Key.service.rawValue,
            kSecAttrAccount as String: Key.email.rawValue,
            kSecValueData as String: emailData,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
    
    public func getEmail() -> String? {

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Key.service.rawValue,
            kSecAttrAccount as String: Key.email.rawValue,
            kSecReturnData as String: true  // 데이터 반환 요청
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == errSecSuccess,
              let data = item as? Data,
              let email = String(data: data, encoding: .utf8) else {
            return nil
        }

        return email
    }
    
    public func deleteEmail() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Key.service.rawValue,
            kSecAttrAccount as String: Key.email.rawValue
        ]
        SecItemDelete(query as CFDictionary)
    }
}

// MARK: - JWT 토큰 관리
extension KeychainStorage {
    public func saveToken(_ tokens: Data) {
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Key.service.rawValue,
            kSecAttrAccount as String: Key.token.rawValue,
            kSecValueData as String: tokens
        ]
        
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess,
              let token = try? JSONDecoder().decode(Token.self, from: tokens) else {
            return
        }
        
        print(#function, #line, "token info : \(token)" )
                
        Self.cachedToken = token
    }
    
    public func getToken() -> Token? {
        if let token = Self.cachedToken {
            return token
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Key.service.rawValue,
            kSecAttrAccount as String: Key.token.rawValue,
            kSecReturnData as String: true  // 데이터 반환 요청
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        guard status == errSecSuccess,
              let data = item as? Data,
              let token = try? JSONDecoder().decode(Token.self, from: data) else {
            return nil
        }
        Self.cachedToken = token
        
        return token
    }
    
    public func deleteToken() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Key.service.rawValue,
            kSecAttrAccount as String: Key.token.rawValue
        ]
        SecItemDelete(query as CFDictionary)
    }

    public func hasToken() -> Bool {
        return getToken() != nil
    }

    public func reissueToken(accessToken: String) {
        Self.cachedToken?.accessToken = accessToken
        guard let tokenData = try? JSONEncoder().encode(Self.cachedToken) else { return }
        self.saveToken(tokenData)
    }
}
