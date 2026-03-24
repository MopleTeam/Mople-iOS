//
//  FetchPlanDetail.swift
//  Mople
//
//  Created by CatSlave on 1/11/25.
//
import Foundation
import RxSwift

protocol FetchPlanDetail {
    func execute(planId: Int) -> Observable<Plan>
}

final class FetchPlanDetailUseCase: FetchPlanDetail {
    
    private let repo: PlanRepo
    private let userID = UserInfoStorage.shared.userInfo?.id
    
    init(repo: PlanRepo) {
        self.repo = repo
    }
    
    func execute(planId: Int) -> Observable<Plan> {
        return repo.fetchPlanDetail(planId: planId)
            .map { $0.toDomain() }
            .map { [weak self] plan in
                var verifyPlan = plan
                verifyPlan.verifyCreator(self?.userID)
                return verifyPlan
            }
            .asObservable()
    }
}

// MARK: - Mock UseCase
#if DEV
final class MockFetchPlanDetailUseCase: FetchPlanDetail {
    func execute(planId: Int) -> Observable<Plan> {
        print("✅ [Mock] 일정 상세 조회 - planId: \(planId)")

        let mockPlan = Plan(
            id: planId,
            creatorId: 1,
            title: "주말 테니스 모임",
            date: Calendar.current.date(byAdding: .day, value: 3, to: Date()),
            participationCount: 5,
            isParticipation: true,
            addressTitle: "올림픽공원 테니스장",
            address: "서울특별시 송파구 올림픽로 424",
            meet: MeetSummary(id: 1, name: "테니스 동호회"),
            location: Location(longitude: 127.115921, latitude: 37.520407),
            weather: Weather(address: "송파구", imagePath: nil, temperature: 18.5, pop: 0.1),
            isCreator: true,
            commentCount: 3,
            description: "주말에 테니스 치러 갑시다!"
        )

        return Observable.just(mockPlan)
            .delay(.seconds(1), scheduler: MainScheduler.instance)
    }
}
#endif

