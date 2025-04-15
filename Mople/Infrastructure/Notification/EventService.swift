//
//  NotificationService.swift
//  Mople
//
//  Created by CatSlave on 1/15/25.
//
import UIKit
import RxSwift

// MARK: - 아이템 타입
typealias MeetPayload = EventService.Payload<Meet>
typealias PlanPayload = EventService.Payload<Plan>
typealias ReviewPayload = EventService.Payload<Review>

final class EventService {
    
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
    
    static let shared = EventService()
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
    
    // MARK: - Log
    private func log(from sender: String, payload: Any) {
        printIfDebug("Event: sender[\(sender)] payload[\(payload)]")
    }
}

extension Notification.Name {
    static let meet = Notification.Name(String(describing: Meet.self))
    static let plan = Notification.Name(String(describing: Plan.self))
    static let review = Notification.Name(String(describing: Review.self))
    static let participating = Notification.Name("participating")
    static let postReview = Notification.Name("postReview")
    static let midnightUpdate = Notification.Name("midnightUpdate")
    static let sessionExpired = Notification.Name("sessionExpired")
    static let editProfile = Notification.Name("editProfile")
}
