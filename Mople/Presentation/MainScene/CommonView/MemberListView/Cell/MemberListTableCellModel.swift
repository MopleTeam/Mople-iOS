//
//  MemberListTableCellMOdel.swift
//  Mople
//
//  Created by CatSlave on 2/4/25.
//

import Foundation

struct MemberListTableCellModel {
    let nickName: String?
    let imagePath: String?
    let position: MemberPositionType?
}

extension MemberListTableCellModel {
    init(memberInfo: MemberInfo) {
        self.nickName = memberInfo.nickname
        self.imagePath = memberInfo.imagePath
        self.position = memberInfo.position
    }
}
