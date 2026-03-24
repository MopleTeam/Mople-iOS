//
//  ValidativeNickname.swift
//  Mople
//
//  Created by CatSlave on 1/20/25.
//

import RxSwift

protocol CheckDuplicateNickname {
    func execute(_ nickname: String) -> Observable<Bool>
}

final class CheckDuplicateNicknameUseCase: CheckDuplicateNickname {
    
    private let duplicateCheckRepo: NicknameRepo
    
    init(duplicateCheckRepo: NicknameRepo) {
        self.duplicateCheckRepo = duplicateCheckRepo
    }
        
    func execute(_ nickname: String) -> Observable<Bool> {
        return duplicateCheckRepo.isNicknameExists(nickname)
            .map { String(data: $0, encoding: .utf8) }
            .map { self.handleRequestValue($0) }
            .asObservable()
    }
    
    private func handleRequestValue(_ value: String?) -> Bool {
        switch value {
        case "true": return true
        default: return false
        }
    }
}

// MARK: - Mock UseCase
#if DEV
final class MockCheckDuplicateNicknameUseCase: CheckDuplicateNickname {

    func execute(_ nickname: String) -> Observable<Bool> {
        print("✅ [Mock] 닉네임 중복 확인 요청 - nickname: \(nickname)")
        return Observable.just(false)
            .delay(.seconds(1), scheduler: MainScheduler.instance)
            .do(onNext: { print("✅ [Mock] 닉네임 중복 확인 완료 - isDuplicate: \($0)") })
    }
}
#endif
