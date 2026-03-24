//
//  FetchRecentMeeting.swift
//  Group
//
//  Created by CatSlave on 8/31/24.

import Foundation
import RxSwift

protocol FetchHomeData {
    func execute() -> Observable<HomeData>
}

final class FetchHomeDataUseCase: FetchHomeData {
    private let repo: PlanRepo
    private let userID = UserInfoStorage.shared.userInfo?.id
    
    init(repo: PlanRepo) {
        self.repo = repo
    }
    
    func execute() -> Observable<HomeData> {
        return repo.fetchHomeData()
            .map { $0.toDomain() }
            .map({
                var newHomeData = $0
                self.verifyCreator(with: &newHomeData.plans)
                return newHomeData
            })
            .asObservable()
    }
    
    private func verifyCreator(with planList: inout [Plan]) {
        guard let userID else { return }
        planList.enumerated().forEach { index, plan in
            planList[index].verifyCreator(userID)
        }
    }
}

// MARK: - Mock UseCase
#if DEV
final class MockFetchHomeDataUseCase: FetchHomeData {
    func execute() -> Observable<HomeData> {
        print("✅ [Mock] 홈 데이터 조회")

        let calendar = Calendar.current
        let currentDate = Date()

        let mockPlans: [Plan] = (1...5).map { index in
            Plan(
                id: index,
                creatorId: index % 2 == 0 ? 1 : 99,
                title: ["테니스 모임", "독서 토론", "등산 계획", "맛집 탐방", "영화 관람"][index - 1],
                date: calendar.date(byAdding: .day, value: index, to: currentDate),
                participationCount: index + 1,
                isParticipation: index % 2 == 0,
                addressTitle: ["광화문", "강남역", "홍대입구", "잠실", "여의도"][index - 1],
                address: "서울특별시",
                meet: MeetSummary(id: index, name: "모임 \(index)"),
                location: Location(longitude: 126.976894, latitude: 37.575968),
                weather: Weather(address: "서울", imagePath: nil, temperature: 20.0, pop: 0.2),
                isCreator: index % 2 == 0,
                commentCount: index,
                description: "Mock 홈 일정 \(index)"
            )
        }

        let homeData = HomeData(plans: mockPlans, hasMeet: true)

        return Observable.just(homeData)
            .delay(.seconds(1), scheduler: MainScheduler.instance)
    }
}
#endif

