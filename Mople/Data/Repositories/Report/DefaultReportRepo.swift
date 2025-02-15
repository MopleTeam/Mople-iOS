//
//  DefaultReportRepo.swift
//  Mople
//
//  Created by CatSlave on 2/14/25.
//

import RxSwift

final class DefaultReportRepo: BaseRepositories, ReportRepo {
    func reportPost(type: ReportType) -> Single<Void> {
        networkService.authenticatedRequest {
            return try APIEndpoints.report(type: type)
        }
    }
}
