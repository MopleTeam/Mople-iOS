//
//  Report.swift
//  Mople
//
//  Created by CatSlave on 2/14/25.
//

import RxSwift

protocol ReportPost {
    func execute(type: ReportType,
                 reason: String?) -> Observable<Void>
}

final class ReportPostUseCase: ReportPost {
    
    private let repo: ReportRepo
    
    init(repo: ReportRepo) {
        self.repo = repo
    }
    
    func execute(type: ReportType,
                 reason: String? = nil) -> Observable<Void> {
        let request: ReportRequest = .init(type: type, reason: reason)
        return repo.reportPost(request: request)
            .asObservable()
    }
}

// MARK: - Mock
#if DEV
final class MockReportPostUseCase: ReportPost {
    func execute(type: ReportType,
                 reason: String?) -> Observable<Void> {
        print("✅ [Mock] 게시글 신고 - type: \(type), reason: \(reason ?? "없음")")
        return Observable.just(())
            .delay(.seconds(1), scheduler: MainScheduler.instance)
    }
}
#endif

