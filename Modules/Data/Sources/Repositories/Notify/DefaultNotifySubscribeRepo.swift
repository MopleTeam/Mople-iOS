//
//  DefaultNotifiSubscribeRepo.swift
//  Mople
//
//  Created by CatSlave on 4/14/25.
//

import Domain

public final class DefaultNotifySubscribeRepo: BaseRepositories, NotifySubscribeRepo {
    public func fetchNotifyState() async throws -> [String] {
        return try await networkService.authenticatedRequest {
            try APIEndpoints.fetchNotifyState()
        }
    }

    public func subscribeNotify(type: SubscribeType, isSubscribe: Bool) async throws {
        return try await networkService.authenticatedRequest {
            try APIEndpoints.subscribeMeetNotify(type: type,
                                                 isSubscribe: isSubscribe)
        }
    }
}
    
    
public final class DefaultNotifyStatusQueryRepo: BaseRepositories {

}
