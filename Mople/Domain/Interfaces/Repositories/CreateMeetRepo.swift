//
//  CreateGroupRepository.swift
//  Group
//
//  Created by CatSlave on 11/19/24.
//

import Foundation
import RxSwift

protocol CreateMeetRepo {
    func createMeet(title: String, imagePath: String?) -> Single<Void>
}
