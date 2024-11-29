//
//  CreateGroupRepository.swift
//  Group
//
//  Created by CatSlave on 11/19/24.
//

import Foundation
import RxSwift

protocol CreateGroupRepo {
    func makeGroup(title: String, imagePath: String?) -> Single<Void>
}
