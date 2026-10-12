//
//  VesionCheckRepository.swift
//  Mople
//
//  Created by CatSlave on 6/12/25.
//

import Foundation

public protocol AppVersionRepo {
    func checkForceUpdate() async throws -> UpdateStatus
}
