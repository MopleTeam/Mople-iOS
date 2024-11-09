//
//  AppDesign+DatePicker.swift
//  Group
//
//  Created by CatSlave on 11/10/24.
//

import UIKit

extension AppDesign {
    
    enum DatePicker: UIConstructive {
        
        static let completeButtonColor: UIColor = AppDesign.defaultBlue
        static let closeImage = UIImage(named: "close")
        
        case header
        case pickerComplete
    
        var itemConfig: ItemConfigure {
            switch self {
                
            case .header:
                return makeUIConfigure(font: FontStyle.Title3.semiBold,
                                       color: AppDesign.defaultBlack,
                                       image: UIImage(named: "arrow"))
        
            case .pickerComplete:
                return makeUIConfigure(text: "완료",
                                       font: FontStyle.Title3.semiBold,
                                       color: AppDesign.defaultWihte)
            }
        }
    }
}
