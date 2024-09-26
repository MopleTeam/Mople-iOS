//
//  ScheduleTableViewModel.swift
//  Group
//
//  Created by CatSlave on 9/24/24.
//

import Foundation
import Differentiator

struct ScheduleTableModel: SectionModelType {
    
    var dateComponents: DateComponents
    var items: [Item] = []
    
    var headerText: String? {
        guard let date = DateManager.calendar.date(from: dateComponents) else { return nil }
        
        return DateManager.simpleDateFormatter.string(from: date)
    }
}

extension ScheduleTableModel {
    
    typealias Item = Schedule
    
    init(original: ScheduleTableModel, items: [Schedule]) {
        self = original
        self.items = items
    }
}
