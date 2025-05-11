//
//  NotificationService.swift
//  Mople
//
//  Created by CatSlave on 1/15/25.
//
import UIKit
import RxSwift

// MARK: - 아이템 타입
typealias MeetPayload = NotificationManager.Payload<Meet>
typealias PlanPayload = NotificationManager.Payload<Plan>
typealias ReviewPayload = NotificationManager.Payload<Review>

final class NotificationManager {
    
    enum Payload<T> {
        case created(T)
        case updated(T)
        case deleted(id: Int)
        
        var notiName: Notification.Name {
            switch T.self {
            case is Meet.Type: return .meet
            case is Plan.Type: return .plan
            case is Review.Type: return .review
            default: return .init("Default")
            }
        }
    }
    
    enum ParticipationPayload {
        case participating(Plan)
        case notParticipation(id: Int)
    }
    
    static let shared = NotificationManager()
    private init() {}
    private let payloadKey = "payload"
    private let senderKey = "sender"
    
    // MARK: - Void
    func post(name: Notification.Name) {
        NotificationCenter.default.post(name: name, object: nil)
    }
    
    func addObservable(name: Notification.Name) -> Observable<Void> {
        return NotificationCenter.default.rx.notification(name)
            .map { _ in }
    }
    
    // MARK: - Payload
    func postItem<T>(_ payload: Payload<T>, from sender: Any) {
        NotificationCenter.default.post(name: payload.notiName,
                                        object: nil,
                                        userInfo: [payloadKey:payload,
                                                    senderKey: String(describing: sender)])
    }
    
    func addMeetObservable() -> Observable<MeetPayload> {
        return makeObservable(name: .meet)
    }

    func addPlanObservable() -> Observable<PlanPayload> {
        return makeObservable(name: .plan)
    }
    
    func addReviewObservable() -> Observable<ReviewPayload> {
        return makeObservable(name: .review)
    }
    
    // MARK: - Participating
    func postParticipating(_ payload: ParticipationPayload, from sender: Any) {
        NotificationCenter.default.post(name: .participating,
                                        object: nil,
                                        userInfo: [payloadKey: payload,
                                                    senderKey: String(describing: sender)])
    }
    
    func addParticipatingObservable() -> Observable<PlanPayload> {
        let participatingObservable: Observable<ParticipationPayload> = makeObservable(name: .participating)
        return participatingObservable.map {
            switch $0 {
            case let .participating(plan):
                return .created(plan)
            case let .notParticipation(id):
                return .deleted(id: id)
            }
        }
    }
    
    // MARK: - Payload Observable
    private func makeObservable<T>(name: Notification.Name) -> Observable<T> {
        return NotificationCenter.default.rx.notification(name, object: nil)
            .share(replay: 1)
            .compactMap { [weak self] in
                guard let self,
                      let sender = $0.userInfo?[self.senderKey] as? String,
                      let payload = $0.userInfo?[self.payloadKey] as? T else { return nil }
                self.log(from: sender, payload: payload)
                return payload
            }
    }

    // MARK: - Scene Observable
    func addEnterForeGroundObservable() -> Observable<Notification> {
        return NotificationCenter.default.rx.notification(UIApplication.willEnterForegroundNotification)
    }
    
    // MARK: - Log
    private func log(from sender: String, payload: Any) {
        printIfDebug("Event: sender[\(sender)] payload[\(payload)]")
    }
}


// MARK: - Event Name
extension Notification.Name {
    
    /// 모임
    static let meet = Notification.Name(String(describing: Meet.self))
    
    /// 일정
    static let plan = Notification.Name(String(describing: Plan.self))
    
    /// 후기
    static let review = Notification.Name(String(describing: Review.self))
    
    /// 일정 참여
    static let participating = Notification.Name("participating")
    
    /// 후기 작성
    static let postReview = Notification.Name("postReview")
    
    /// 자정 업데이트
    static let midnightUpdate = Notification.Name("midnightUpdate")
    
    /// 토큰 만료
    static let sessionExpired = Notification.Name("sessionExpired")
    
    /// 프로필 수정
    static let editProfile = Notification.Name("editProfile")
    
    /// 알림 카운트 업데이트
    static let changedNotifyCount = Notification.Name("changedNotifyCount")
    
    /// FCM 토큰
    static let updateFCMToken = Notification.Name("updateFCMToken")
}
