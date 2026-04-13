//
//  MemberListSectionModel.swift
//  Mople
//
//  Created by CatSlave on 6/6/25.
//

import Differentiator
import Domain

struct MembersSectionModel: SectionModelType {
    var items: [MemberInfo] = []
}

extension MembersSectionModel {
    
    init(original: MembersSectionModel, items: [MemberInfo]) {
        self = original
        self.items = items
    }
}
