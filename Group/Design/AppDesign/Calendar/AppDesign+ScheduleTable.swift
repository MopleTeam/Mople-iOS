//
//  AppDesign+ScheduleTable.swift
//  Group
//
//  Created by CatSlave on 11/10/24.
//

import Foundation

extension AppDesign {
    
    enum SchedeleTable: UIConstructive {
        
        case header
        
        var itemConfig: ItemConfigure {
            switch self {
                
            case .header:
                return makeUIConfigure(font: FontStyle.Body1.medium,
                                       color: .init(hexCode: "999999"))
            }
        }
    }
}
