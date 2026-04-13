//
//  MemberPositionType+Image.swift
//  Mople
//
//  Created by CatSlave on 4/10/26.
//

import UIKit

/// Domain의 MemberPositionType에 UIImage 매핑을 추가하는 Presentation 확장
extension MemberPositionType {
    var image: UIImage? {
        switch self {
        case .owner:
            return .owner
        case .host:
            return .host
        case .member:
            return nil
        }
    }
}
