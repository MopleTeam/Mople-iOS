//
//  ReportComment.swift
//  Mople
//
//  Created by CatSlave on 2/2/25.
//

import RxSwift

protocol ReportComment {
    func execute(comment: ReportCommentRequest) -> Single<Void>
}

final class ReportCommentUseCase: ReportComment {
    
    private let reportCommentRepo: CommentCommandRepo
    
    init(reportCommentRepo: CommentCommandRepo) {
        self.reportCommentRepo = reportCommentRepo
    }
    
    func execute(comment: ReportCommentRequest) -> Single<Void> {
        return reportCommentRepo
            .reportComment(comment)
    }
}
