//
//  DetailSchedule.swift
//  Group
//
//  Created by CatSlave on 11/7/24.
//

import Foundation

struct DetailSchedule: Schedulable {
    let commonScheudle: CommonSchedule?
    let location: LocationInfo?
    let participants: [UserInfo]
    let comments: [Comment]
}
