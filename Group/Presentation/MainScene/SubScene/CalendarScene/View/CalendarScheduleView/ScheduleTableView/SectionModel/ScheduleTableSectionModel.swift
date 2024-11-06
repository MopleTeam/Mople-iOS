//
//  ScheduleTableViewModel.swift
//  Group
//
//  Created by CatSlave on 9/24/24.
//

import Foundation
import Differentiator

struct ScheduleTableSectionModel: SectionModelType {
    
    var date: Date?
    var items: [Item] = []
    
    var title: String? {
        guard let dateComponents = date else { return nil }
        return DateManager.simpleDateFormatter.string(from: dateComponents)
    }
}

extension ScheduleTableSectionModel {
    
    typealias Item = Plan
    
    init(original: ScheduleTableSectionModel, items: [Plan]) {
        self = original
        self.items = items
    }
}
