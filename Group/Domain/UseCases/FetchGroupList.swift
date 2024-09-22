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


