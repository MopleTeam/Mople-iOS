//
//  AppDesign+Navi.swift
//  Group
//
//  Created by CatSlave on 11/10/24.
//

import Foundation

extension AppDesign {
    enum Navi: UIConstructive {
        case NaviView
        
        var itemConfig: ItemConfigure {
            switch self {
            case .NaviView:
                return makeUIConfigure(font: FontStyle.Title2.bold)
            }
        }
    }
}
