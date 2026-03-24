//
//  VersionCheck.swift
//  Mople
//
//  Created by CatSlave on 6/12/25.
//

import RxSwift

protocol CheckVersion {
    func executue() -> Observable<UpdateStatus>
}

final class CheckVersionUseCase: CheckVersion {

    private let repo: AppVersionRepo
    
    init(repo: AppVersionRepo) {
        self.repo = repo
    }
    
    func executue() -> Observable<UpdateStatus> {
        self.repo.checkForceUpdate()
            .map { $0.toDomain() }
            .asObservable()
    }
}

// MARK: - Mock
#if DEV
final class MockCheckVersionUseCase: CheckVersion {
    func executue() -> Observable<UpdateStatus> {
        print("✅ [Mock] 앱 버전 체크")
        let mockStatus = UpdateStatus(forceUpdate: false,
                                      minVersion: "1.0.0",
                                      message: "")
        return Observable.just(mockStatus)
            .delay(.seconds(1), scheduler: MainScheduler.instance)
    }
}
#endif
