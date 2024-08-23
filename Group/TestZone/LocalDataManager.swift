//
//  LocalDataManager.swift
//  Group_Project
//
//  Created by CatSlave on 7/23/24.
//

import Foundation

class LocalDataManager {
    
    static let shared = LocalDataManager()
    
    var identifierNumber: Int = 10
    
    private init() { }
    
    let localData = UserDefaults.standard
    
    enum Key: String {
        case deviceToken
        case userID
        case url
        case reUrl
    }
    
    func saveDeviceToken(token: String) {
        localData.setValue(token, forKey: Key.deviceToken.rawValue)
    }

    func saveApsUrl(url: String) {
        localData.setValue(url, forKey: Key.url.rawValue)
    }

    func loadToken() -> String? {
        guard let token = localData.string(forKey: Key.deviceToken.rawValue) else {
            return nil
        }
        return token
    }

    func loadEnterUrl() -> String? {
        guard let url = localData.string(forKey: Key.url.rawValue) else { return nil }
        
        return url
    }

}
