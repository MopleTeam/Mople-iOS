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
