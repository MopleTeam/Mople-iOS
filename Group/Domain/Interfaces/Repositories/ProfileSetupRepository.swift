//
//  SetupProfileRepository.swift
//  Group
//
//  Created by CatSlave on 8/26/24.
//

import Foundation
import RxSwift

protocol ProfileSetupRepository {
    func checkNickname(name: String) -> Single<Bool>
    func makeProfile(image: Data, nickNmae: String) -> Single<Void>
}
