//
//  Location.swift
//  Mople
//
//  Created by CatSlave on 12/10/24.
//

import Foundation
import RealmSwift

struct Location: Hashable {
    let longitude: Double?
    let latitude: Double?
}

extension Location {
    static var defaultLocation: Self {
        return .init(longitude: 126.976894, latitude: 37.575968)
    }
}
