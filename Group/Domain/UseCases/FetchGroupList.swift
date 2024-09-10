//
//  FetchGroupList.swift
//  Group
//
//  Created by CatSlave on 9/10/24.
//

import Foundation
import RxSwift

protocol FetchGroupList {
    func fetchGroupList() -> Single<[Group]>
}

struct Group {
    let thumbnailPath: String
    let name: String
    let memberCount: Int
    let lastSchedule: Date
}
