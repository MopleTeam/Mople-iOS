//
//  ScheduleTableViewModel.swift
//  Group
//
//  Created by CatSlave on 9/24/24.
//

import Foundation
import Differentiator

struct PlanTableSectionModel: SectionModelType {
    
    var date: Date?
    var items: [Item] = []
    
    var title: String? {
        guard let dateComponents = date else { return nil }
        return DateManager.simpleDateFormatter.string(from: dateComponents)
    }
    
    static func < (lhs: PlanTableSectionModel, rhs: PlanTableSectionModel) -> Bool {
        guard let lhsDate = lhs.date,
              let rhsDate = rhs.date else { return false }
        
        return lhsDate < rhsDate
    }
}

extension PlanTableSectionModel {
    
    typealias Item = Plan
    
    init(original: PlanTableSectionModel, items: [Plan]) {
        self = original
        self.items = items
    }
}
