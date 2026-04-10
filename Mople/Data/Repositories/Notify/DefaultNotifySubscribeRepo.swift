//
//  DefaultNotifiSubscribeRepo.swift
//  Mople
//
//  Created by CatSlave on 4/14/25.
//

final class DefaultNotifySubscribeRepo: BaseRepositories, NotifySubscribeRepo {
    func fetchNotifyState() async throws -> [String] {
        return try await networkService.authenticatedRequest {
            try APIEndpoints.fetchNotifyState()
        }
    }

    func subscribeNotify(type: SubscribeType, isSubscribe: Bool) async throws {
        return try await networkService.authenticatedRequest {
            try APIEndpoints.subscribeMeetNotify(type: type,
                                                 isSubscribe: isSubscribe)
        }
    }
}
    
    
final class DefaultNotifyStatusQueryRepo: BaseRepositories {
    
}
