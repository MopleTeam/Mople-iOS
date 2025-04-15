//
//  NavigationCloseable.swift
//  Mople
//
//  Created by CatSlave on 1/13/25.
//

import Foundation

protocol NavigationCloseable: AnyObject {
    func dismiss(completion: (() -> Void)?)
    func pop()
}
