//
//  Schedulable.swift
//  Group
//
//  Created by CatSlave on 11/7/24.
//

import Foundation

protocol Schedulable {
    var commomScheudle: CommonSchedule? { get }
}

extension Schedulable {
    var id: Int? { commomScheudle?.id }
    var title: String? { commomScheudle?.title }
    var date: Date? { commomScheudle?.date }
    var address: String? { commomScheudle?.address }
    var detailAddress: String? { commomScheudle?.detailAddress }
    var participants: [UserInfo] { commomScheudle?.participants ?? [] }
    var weather: WeatherInfo? { commomScheudle?.weather }
    var startOfDate: Date? { commomScheudle?.startOfDate }
}

struct CommonSchedule: Hashable, Equatable {
    let id: Int?
    let title: String?
    let date: Date?
    let address: String?
    let detailAddress: String?
    let participants: [UserInfo]
    let weather: WeatherInfo?
}

extension CommonSchedule {
    var startOfDate: Date? {
        guard let date = date else { return nil }
        return DateManager.startOfDay(date)
    }
}
