//
//  ScheduleTableViewModel.swift
//  Group
//
//  Created by CatSlave on 9/24/24.
//

import Foundation
import Differentiator

struct PostListSectionModel: SectionModelType {
    
    var date: Date?
    var items: [Item] = []
    
    var title: String? {
        guard let dateComponents = date else { return nil }
        return DateManager.basicDateFormatter.string(from: dateComponents)
    }
    
    static func < (lhs: PostListSectionModel, rhs: PostListSectionModel) -> Bool {
        guard let lhsDate = lhs.date,
              let rhsDate = rhs.date else { return false }
        
        return lhsDate < rhsDate
    }
}

extension PostListSectionModel {
    
    typealias Item = MonthlyPost
    
    init(original: PostListSectionModel, items: [MonthlyPost]) {
        self = original
        self.items = items
    }
}

extension [PostListSectionModel] {
    static func makeSectionModels(list: [MonthlyPost]) -> Self {
        let sortList = list.sorted {
            guard let date1 = $0.date,
                  let date2 = $1.date else { return false }
            return date1 < date2
        }
        let grouped = Dictionary(grouping: sortList) { plan -> Date? in
            guard let date = plan.date else { return nil }
            return DateManager.startOfDay(date)
        }
        
        let sorted = grouped.sorted { first, second in
            guard let firstDate = first.key,
                  let secondDate = second.key else { return false }
            return firstDate < secondDate
        }
        
        return sorted.map { PostListSectionModel(date: $0.key, items: $0.value) }
    }
}
