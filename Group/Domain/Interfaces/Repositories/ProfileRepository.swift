//
//  SetupProfileRepository.swift
//  Group
//
//  Created by CatSlave on 8/26/24.
//

import Foundation
import RxSwift

protocol ProfileRepository {
    func getRandomNickname() -> Single<Data>
    func checkNickname(name: String) -> Single<Bool>
    func makeProfile(image: Data, nickname: String) -> Single<Void>
}
