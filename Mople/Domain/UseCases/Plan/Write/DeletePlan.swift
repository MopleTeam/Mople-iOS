//
//  DeletePlan.swift
//  Mople
//
//  Created by CatSlave on 2/21/25.
//

import Foundation
import RxSwift

protocol DeletePlan {
    func execute(id: Int) -> Observable<Void>
}

final class DeletePlanUseCase: DeletePlan {
    
    let repo: PlanRepo
    
    init(repo: PlanRepo) {
        self.repo = repo
    }
    
    func execute(id: Int) -> Observable<Void> {
        return repo.deletePlan(id: id)
            .asObservable()
    }
}

// MARK: - Mock UseCase
#if DEV
final class MockDeletePlanUseCase: DeletePlan {
    func execute(id: Int) -> Observable<Void> {
        print("✅ [Mock] 일정 삭제 - planId: \(id)")

        return Observable.just(())
            .delay(.seconds(1), scheduler: MainScheduler.instance)
    }
}
#endif
