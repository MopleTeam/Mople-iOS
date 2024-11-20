//
//  CommonGroup.swift
//  Group
//
//  Created by CatSlave on 11/8/24.
//

import Foundation

protocol Groupable {
    var commonGroup: CommonGroup? { get }
}

extension Groupable {
    var id: Int? { commonGroup?.id }
    var name: String? { commonGroup?.name }
    var thumbnailPath: String? { commonGroup?.thumbnailPath }
}

struct CommonGroup: Hashable, Equatable {
    var id: Int?
    var name: String?
    var thumbnailPath: String?
}
