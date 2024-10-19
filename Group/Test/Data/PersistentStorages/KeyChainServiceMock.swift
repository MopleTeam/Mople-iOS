//
//  KeyChainServiceMock.swift
//  Group
//
//  Created by CatSlave on 8/31/24.
//

import Foundation

struct KeyChainServiceMock: KeyChainService {
    
    func saveToken(_ token: Data) {
        
    }
    
    func getToken() -> TokenDTO? {
        return nil
    }
    
    func deleteToken() {
        
    }
    
    func hasToken() -> Bool {
        return true
    }
    
    func reissueToken(accessToken: String) {
        return
    }
}
