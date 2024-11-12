//
//  AppColor.swift
//  Group
//
//  Created by CatSlave on 8/13/24.
//

import UIKit

typealias ItemConfigure = (text: String?, font: UIFont?, color: UIColor?, image: UIImage?)

protocol UIConstructive {
    var itemConfig: ItemConfigure { get }
}

extension UIConstructive {
    var itemConfig: ItemConfigure { ItemConfigure(text: nil, font: nil, color: nil, image: nil) }
    
    func makeUIConfigure(text: String? = nil,
                         font: UIFont? = nil,
                         color: UIColor? = nil,
                         image: UIImage? = nil) -> ItemConfigure {
        return (text, font, color, image)
    }
}

struct AppDesign {
    
    enum Primary {
        static let bgColor = ColorStyle.App.primary
    }
    
    enum Navi: UIConstructive {
        case header
        
        var itemConfig: ItemConfigure {
            switch self {
            case .header:
                makeUIConfigure(font: FontStyle.Title2.bold)
            }
        }
    }
    
    enum TabBar {
        static let bgColor = ColorStyle.Default.white
        static let font = FontStyle.App.tabbar
        static let titleColor = ColorStyle.Gray._05
        static let normalColor = ColorStyle.App.icon
        static let selectedColor = ColorStyle.App.secondary
    }
    
    enum Layer {
        static let lineColor = ColorStyle.App.stroke
        static let shadowColor = ColorStyle.Gray._01
    }
}







