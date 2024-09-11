//
//  UIViewController+PreView.swift
//  Group
//
//  Created by CatSlave on 9/11/24.
//

import SwiftUI

@available(iOS 13, *)
extension UIViewController {
    // source: https://fluffy.es/xcode-previews-uikit/
    private struct Preview: UIViewControllerRepresentable {
        // this variable is used for injecting the current view controller
        let viewController: UIViewController
        
        func makeUIViewController(context: Context) -> UIViewController {
            return viewController
        }
        
        func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
            //
        }
    }
    
    @available(iOS 13, *)
    func showPreview() -> some View {
        Preview(viewController: self)
    }
}
