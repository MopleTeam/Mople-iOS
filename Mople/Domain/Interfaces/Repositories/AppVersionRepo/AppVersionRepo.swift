//
//  VesionCheckRepository.swift
//  Mople
//
//  Created by CatSlave on 6/12/25.
//

import Foundation
import RxSwift

protocol AppVersionRepo {
    func checkForceUpdate() -> Single<UpdateStatusResponse>
}
