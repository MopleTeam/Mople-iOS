//
//  FetchUserInfo.swift
//  Mople
//
//  Created by CatSlave on 1/20/25.
//
import UIKit
import RxSwift

protocol FetchUserInfo {
    func execute() -> Observable<Void>
}

final class FetchUserInfoUseCase: FetchUserInfo {
    
    private let userInfoRepo: UserInfoRepo
    
    init(userInfoRepo: UserInfoRepo) {
        self.userInfoRepo = userInfoRepo
    }
    
    func execute() -> Observable<Void> {
        return self.userInfoRepo.updateUserInfo()
            .asObservable()
    }
}

// MARK: - Mock UseCase
#if DEV
final class MockFetchUserInfoUseCase: FetchUserInfo {

    func execute() -> Observable<Void> {
        print("✅ [Mock] 유저 정보 조회 요청")
        return Observable.just(())
            .delay(.seconds(1), scheduler: MainScheduler.instance)
            .do(onNext: { print("✅ [Mock] 유저 정보 조회 성공") })
    }
}
#endif
