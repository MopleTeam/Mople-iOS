//
//  NotifyRespository.swift
//  Mople
//
//  Created by CatSlave on 4/10/25.
//

protocol NotifyRepo {
    func fetchNotifyList(cursor: String?) async throws -> Page<Notify>
    func resetNotifyCount() async throws
}
