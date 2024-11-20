//
//  UIView+PreView.swift
//  Group
//
//  Created by CatSlave on 9/11/24.
//

import SwiftUI

@available(iOS 13.0, *)
extension UIView {
    private struct Preview: UIViewRepresentable {
        let view: UIView
        
        func makeUIView(context: Context) -> UIView {
            return view
        }
        
        func updateUIView(_ uiView: UIView, context: Context) {
            uiView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            uiView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        }
    }
    
    func showPreview() -> some View {
        Preview(view: self)
    }
}
