//
//  SheetManager.swift
//  Mople
//
//  Created by CatSlave on 4/16/25.
//

import UIKit

struct DefaultSheetAction {
    
    let text: String?
    let image: UIImage?
    let completion: (() -> Void)?
    
    init(text: String?,
         image: UIImage?,
         completion: (() -> Void)? = nil) {
        self.text = text
        self.image = image
        self.completion = completion
    }
}

final class SheetManager {
    
    static let shared = SheetManager()
    
    private init() { }
    
    private var currentVC: UIViewController? {
        UIApplication.shared.topVC
    }
    
    func showSheet(actions: [DefaultSheetAction],
                   cancleAction: (() -> Void)? = nil) {
        let alert = DefaultSheetViewController(actions: actions,
                                               cancleAction: cancleAction)
        currentVC?.present(alert, animated: false)
    }
}
