//
//  ReportRepo.swift
//  Mople
//
//  Created by CatSlave on 2/14/25.
//

public protocol ReportRepo {
    func reportPost(request: ReportRequest) async throws
}
