//
//  NotifySubscribe.swift
//  Mople
//
//  Created by CatSlave on 4/11/25.
//

public protocol NotifySubscribeRepo {
    func fetchNotifyState() async throws -> [String]
    func subscribeNotify(type: SubscribeType,
                         isSubscribe: Bool) async throws
}
