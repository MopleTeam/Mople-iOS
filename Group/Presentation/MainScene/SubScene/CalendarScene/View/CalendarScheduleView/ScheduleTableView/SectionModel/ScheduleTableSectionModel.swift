//
//  ScheduleTableViewModel.swift
//  Group
//
//  Created by CatSlave on 9/24/24.
//

import Foundation
import Differentiator

struct ScheduleTableSectionModel: SectionModelType {
    
    var dateComponents: DateComponents
    var items: [DateProviding] = []
    
    var title: String? {
        guard let date = DateManager.calendar.date(from: dateComponents) else { return nil }
        
        return DateManager.simpleDateFormatter.string(from: date)
    }
}

extension ScheduleTableSectionModel {
    
    typealias Item = DateProviding
    
    init(original: ScheduleTableSectionModel, items: [DateProviding]) {
        self = original
        self.items = items
    }
}
