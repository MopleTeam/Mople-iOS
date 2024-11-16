//
//  CreateGroup.swift
//  Group
//
//  Created by CatSlave on 11/16/24.
//

import Foundation
import RxSwift

protocol CreateGroup {
    func createGroup(title: String, imagePath: String?) -> Single<Void>
}
