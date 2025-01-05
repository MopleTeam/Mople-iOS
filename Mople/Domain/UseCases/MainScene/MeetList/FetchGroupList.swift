//
//  FetchGroupList.swift
//  Group
//
//  Created by CatSlave on 9/10/24.
//

import Foundation
import RxSwift

protocol FetchMeetListUseCase {
    func fetchGroupList() -> Single<[Meet]>
}


