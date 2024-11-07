//
//  DetailSchedule.swift
//  Group
//
//  Created by CatSlave on 11/7/24.
//

import Foundation

struct DetailSchedule: Schedulable {
    let commomScheudle: CommonSchedule?
    let location: LocationInfo?
    let comments: [Comment]
}
