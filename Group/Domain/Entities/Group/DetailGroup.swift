//
//  DetailGroup.swift
//  Group
//
//  Created by CatSlave on 11/8/24.
//

import Foundation

struct DetailGroup: Groupable {
    let commonGroup: CommonGroup?
    let members: [UserInfo]
    let lastScheduleDate: Date?
}
