//
//  NotificationService.swift
//  Mople
//
//  Created by CatSlave on 1/15/25.
//
import Foundation
import RxSwift

// MARK: - 아이템 타입
typealias MeetPayload = EventService.Payload<Meet>
typealias PlanPayload = EventService.Payload<Plan>
typealias UserInfoPayload = EventService.Payload<UserInfo>

final class EventService {
    
    static let shared = EventService()
    private init() {}
    
    enum Payload<T> {
        case created(T)
        case updated(T)
        case deleted(T)
        
        var notiName: Notification.Name {
            switch T.self {
            case is Meet.Type: return .meet
            case is Plan.Type: return .plan
            case is UserInfo.Type: return .userInfo
            default: return .init("Default")
            }
        }
    }
    
    private let payloadKey = "payload"
    private let senderKey = "sender"
    
    
    func postItem<T>(_ payload: Payload<T>, from sender: Any) {
        NotificationCenter.default.post(name: payload.notiName,
                                        object: nil,
                                        userInfo: [payloadKey:payload,
                                                    senderKey: String(describing: sender)])
    }
    
    func addMeetObservable() -> Observable<MeetPayload> {
        return makeObservable()
    }

    func addPlanObservable() -> Observable<PlanPayload> {
        return makeObservable()
    }
    
    func addUserInfoObservable() -> Observable<UserInfoPayload> {
        return makeObservable()
    }
    
    private func makeObservable<T>() -> Observable<T> {
        return NotificationCenter.default.rx.notification(.meet, object: nil)
            .compactMap { [weak self] in
                guard let self,
                      let sender = $0.userInfo?[self.senderKey] as? String,
                      let payload = $0.userInfo?[self.payloadKey] as? T else { return nil }
                self.log(from: sender, payload: payload)
                return payload
            }
    }
    
    private func log(from sender: String, payload: Any) {
        printIfDebug("Event: sender[\(sender)] payload[\(payload)]")
    }
}

extension Notification.Name {
    static let meet = Notification.Name(String(describing: Meet.self))
    static let plan = Notification.Name(String(describing: Plan.self))
    static let userInfo = Notification.Name(String(describing: UserInfo.self))
}
