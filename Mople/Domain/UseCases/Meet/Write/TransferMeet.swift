//
//  TransferMeet.swift
//  Mople
//
//  Created by CatSlave on 2/22/26.
//

import Foundation
import RxSwift

protocol TransferMeet {
    func execute(meetId: Int, newHostId: Int) -> Observable<Void>
}


// MARK: - Real UseCase (API 연결 후 사용)
final class TransferMeetUseCase: TransferMeet {
    
    let repo: MeetRepo
    
    init(repo: MeetRepo) {
        self.repo = repo
    }
    
    func execute(meetId: Int, newHostId: Int) -> Observable<Void> {
        return repo.transferMeet(meetId: meetId, newHostId: newHostId)
            .asObservable()
    }
}

// MARK: - Mock UseCase (API 연결 전 테스트용)
final class MockTransferMeetUseCase: TransferMeet {
    
    func execute(meetId: Int, newHostId: Int) -> Observable<Void> {
        print("🔄 [Mock] 모임 양도 시작 - meetId: \(meetId), newHostId: \(newHostId)")
        
        // 2초 딜레이로 네트워크 요청 시뮬레이션
        return Observable<Void>.create { observer in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                // 성공 케이스
                print("✅ [Mock] 모임 양도 성공!")
                observer.onNext(())
                observer.onCompleted()
                
                // 실패 케이스를 테스트하려면 아래 주석 해제
                // let error = DataRequestError.networkError(NSError(domain: "MockError", code: 400))
                // observer.onError(error)
            }
            
            return Disposables.create()
        }
    }
}
