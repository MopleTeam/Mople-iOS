//
//  ScheduleTableViewModel.swift
//  Group
//
//  Created by CatSlave on 9/24/24.
//

import Foundation
import Differentiator

struct ScheduleListSectionModel: SectionModelType {
    
    var date: Date?
    var items: [Item] = []
    
    var title: String? {
        guard let dateComponents = date else { return nil }
        return DateManager.basicDateFormatter.string(from: dateComponents)
    }
    
    static func < (lhs: ScheduleListSectionModel, rhs: ScheduleListSectionModel) -> Bool {
        guard let lhsDate = lhs.date,
              let rhsDate = rhs.date else { return false }
        
        return lhsDate < rhsDate
    }
}

extension ScheduleListSectionModel {
    
    typealias Item = MonthlyPlan
    
    init(original: ScheduleListSectionModel, items: [MonthlyPlan]) {
        self = original
        self.items = items
    }
}
