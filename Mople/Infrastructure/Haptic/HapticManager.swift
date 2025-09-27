//
//  HapticManager.swift
//  Mople
//
//  Created by CatSlave on 8/5/25.
//

import UIKit

final class HapticManager {
    static let shared = HapticManager()
    
    private init() { }
    
    public func playHaptics(style: UIImpactFeedbackGenerator.FeedbackStyle = .soft) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}
