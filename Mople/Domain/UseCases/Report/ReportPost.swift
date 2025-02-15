//
//  Report.swift
//  Mople
//
//  Created by CatSlave on 2/14/25.
//

import RxSwift

protocol ReportPost {
    func execute(type: ReportType) -> Single<Void>
}

final class ReportPostUseCase: ReportPost {
    
    private let repo: ReportRepo
    
    init(repo: ReportRepo) {
        self.repo = repo
    }
    
    func execute(type: ReportType) -> Single<Void> {
        return repo.reportPost(type: type)
    }
}

