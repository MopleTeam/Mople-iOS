//
//  RefreshFCMToken.swift
//  Mople
//
//  Created by CatSlave on 12/3/24.
//

import Foundation

protocol ReqseutRefreshFCMToken {
    func refreshFCMToken()
}

final class RefreshFCMTokenUseCase: ReqseutRefreshFCMToken {
    
    let tokenRefreshManager: RefreshFCMToken
    
    init(tokenRefreshManager: RefreshFCMToken) {
        self.tokenRefreshManager = tokenRefreshManager
    }
    
    func refreshFCMToken() {
        tokenRefreshManager.refreshFCMToken()
    }
}
