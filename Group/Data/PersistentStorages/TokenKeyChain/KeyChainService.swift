//
//  KeyChainManager.swift
//  Group
//
//  Created by CatSlave on 7/26/24.
//

import Foundation
import Security

final class KeyChainService {
    
    static let shared = KeyChainService()
    
    private init() {}
    
    private(set) static var cachedToken: TokenDTO?
    
    enum Key: String {
        case service = "com.Side.GroupManager"
        case account = "userToken"
    }
    
    private let service = "com.yourapp.tokens"
    
    private let account = "userTokens"

    func saveToken(_ tokens: Data) {
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Key.service.rawValue,
            kSecAttrAccount as String: Key.account.rawValue,
            kSecValueData as String: tokens
        ]
        
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess,
              let token = try? JSONDecoder().decode(TokenDTO.self, from: tokens) else {
            return
        }
        
        let dataString = String(data: tokens, encoding: .utf8)
        print(#function, #line, "token : \(token), data: \(dataString)" )
        
        Self.cachedToken = token
    }
    
    func getToken() -> TokenDTO? {
        if let token = Self.cachedToken {
            return token
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Key.service.rawValue,
            kSecAttrAccount as String: Key.account.rawValue,
            kSecReturnData as String: true  // 데이터 반환 요청
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        guard status == errSecSuccess,
              let data = item as? Data,
              let token = try? JSONDecoder().decode(TokenDTO.self, from: data) else {
            return nil
        }
        
        Self.cachedToken = token
        
        return token
    }
    
    func deleteToken() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Key.service.rawValue,
            kSecAttrAccount as String: Key.account.rawValue
        ]

        let status = SecItemDelete(query as CFDictionary)
        if status == errSecSuccess {
            print("Tokens deleted successfully")
        } else {
            print("Tokens Failed to delete tokens: \(status)")
        }
    }

    func hasToken() -> Bool {
        return getToken() != nil
    }
    
    func reissueToken(accessToken: String) {
        Self.cachedToken?.accessToken = accessToken
        guard let tokenData = try? JSONEncoder().encode(Self.cachedToken) else { return }
        self.saveToken(tokenData)
    }
}
