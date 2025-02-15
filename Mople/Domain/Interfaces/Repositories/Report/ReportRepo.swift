//
//  ReportRepo.swift
//  Mople
//
//  Created by CatSlave on 2/14/25.
//

import RxSwift

protocol ReportRepo {
    func reportPost(type: ReportType) -> Single<Void>
}
