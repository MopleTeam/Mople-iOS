//
//  DeletePlan.swift
//  Mople
//
//  Created by CatSlave on 2/21/25.
//

import Foundation
import RxSwift

protocol DeletePlan {
    func execute(id: Int) -> Single<Void>
}

final class DeletePlanUseCase: DeletePlan {
    
    let repo: PlanRepo
    
    init(repo: PlanRepo) {
        self.repo = repo
    }
    
    func execute(id: Int) -> Single<Void> {
        return repo.deletePlan(id: id)
    }
}
