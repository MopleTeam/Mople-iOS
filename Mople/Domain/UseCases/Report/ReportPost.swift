//
//  Report.swift
//  Mople
//
//  Created by CatSlave on 2/14/25.
//

import RxSwift

protocol ReportPost {
    func execute(type: ReportType,
                 reason: String?) -> Single<Void>
}

final class ReportPostUseCase: ReportPost {
    
    private let repo: ReportRepo
    
    init(repo: ReportRepo) {
        self.repo = repo
    }
    
    func execute(type: ReportType,
                 reason: String? = nil) -> Single<Void> {
        let request: ReportRequest = .init(type: type, reason: reason)
        return repo.reportPost(request: request)
    }
}

