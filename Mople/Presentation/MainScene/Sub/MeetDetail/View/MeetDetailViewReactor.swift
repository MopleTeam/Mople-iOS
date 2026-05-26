//
//  DetailGroupViewReactor.swift
//  Mople
//
//  Created by CatSlave on 1/5/25.
//

import Foundation
import Domain
import ReactorKit
import Data

protocol MeetDetailDelegate: AnyObject, ChildLoadingDelegate {
    func selectedPlan(id: Int, type: PostType)
    func refresh()
}

enum MeetDetailError: Error {
    case noResponse(ResponseError)
    case midnight(DateTransitionError)
    case unknown(Error)
}

final class MeetDetailViewReactor: Reactor, LifeCycleLoggable {
    
    enum Action {
        enum Flow {
            case switchPage(isFuture: Bool)
            case pushMeetSetupView
            case createPlan
            case endFlow
            case showMeetImage
            case memberList
            case openNoticeList
            case openNoticeDetail
        }

        enum Loading {
            case planLoading(Bool)
            case reviewLoading(Bool)
        }
        
        case fetchMeetInfo
        case refresh
        case flow(Flow)
        case loading(Loading)
        case editMeet(MeetPayload)
        case catchError(MeetDetailError)
    }
    
    enum Mutation {
        case setMeetInfo(meet: Meet)
        case updateMeetInfoLoading(Bool)
        case updatePlanListLoading(Bool)
        case updateReviewListLoading(Bool)
        case updateInviteUrl(String)
        case catchError(MeetDetailError)
    }
    
    struct State {
        @Pulse var meet: Meet?
        @Pulse var inviteUrl: String?
        @Pulse var meetInfoLoaded: Bool = false
        @Pulse var futurePlanLoaded: Bool = false
        @Pulse var pastPlanLoaded: Bool = false
        @Pulse var error: MeetDetailError?
    }
    
    // MARK: - Variables
    var initialState: State = State()
    private let meetId: Int
    private var isLoading = false
    
    // MARK: - UseCase
    private let fetchMeetUseCase: FetchMeetDetail
    private let inviteMeetUseCase: InviteMeet
    
    // MARK: - Coordinator
    private weak var coordinator: MeetDetailCoordination?
    
    // MARK: - Commands
    public weak var planListCommands: MeetPlanListCommands?
    public weak var reviewListCommands: MeetReviewListCommands?
    
    // MARK: - LifeCycle
    init(fetchMeetUseCase: FetchMeetDetail,
         inviteMeetUseCase: InviteMeet,
         coordinator: MeetDetailCoordination,
         meetID: Int) {
        self.fetchMeetUseCase = fetchMeetUseCase
        self.inviteMeetUseCase = inviteMeetUseCase
        self.coordinator = coordinator
        self.meetId = meetID
        initialAction()
        logLifeCycle()
    }
    
    deinit {
        logLifeCycle()
    }
    
    // MARK: - Initial Setup
    private func initialAction() {
        action.onNext(.fetchMeetInfo)
    }
    
    // MARK: - State Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchMeetInfo:
            return fetchMeetInfo()
        case let .editMeet(payload):
            return handleMeetPayload(with: payload)
        case .refresh:
            return resetPost()
        case let .loading(action):
            return handleChildLoading(action)
        case let .flow(action):
            return handleFlowAction(action)
        case let .catchError(err):
            return .just(.catchError(err))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case let .setMeetInfo(meet):
            newState.meet = meet
        case let .updateInviteUrl(url):
            newState.inviteUrl = url
        case let .updateMeetInfoLoading(isLoading):
            newState.meetInfoLoaded = isLoading
        case let .updatePlanListLoading(isLoading):
            newState.futurePlanLoaded = isLoading
        case let .updateReviewListLoading(isLoading):
            newState.pastPlanLoaded = isLoading
        case let .catchError(err):
            newState.error = err
        }
        
        return newState
    }
}

// MARK: - Data Request
extension MeetDetailViewReactor {
    /// 모임 정보 불러오기 (async UseCase를 Observable로 래핑)
    private func fetchMeetInfo() -> Observable<Mutation> {
        let fetchMeet = Observable<Mutation>.create { [weak self] observer in
            let task = Task { [weak self] in
                do {
                    guard let self else { return }
                    let meet = try await self.fetchMeetUseCase.execute(meetId: self.meetId)
                    self.fetchPost()
                    observer.onNext(.setMeetInfo(meet: meet))
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
            }
            return Disposables.create { task.cancel() }
        }

        return requestWithLoading(task: fetchMeet)
    }
}

// MARK: - Coordinator
extension MeetDetailViewReactor {
    private func handleFlowAction(_ action: Action.Flow) -> Observable<Mutation> {
        switch action {
        case let .switchPage(isFuture):
            coordinator?.swicthPlanListPage(isFuture: isFuture)
        case .pushMeetSetupView:
            guard let meet = currentState.meet else { return .empty() }
            coordinator?.pushMeetSetupView(meet: meet)
        case .createPlan:
            guard let meet = currentState.meet?.meetSummary else { return .empty() }
            coordinator?.presentPlanCreateView(meet: meet)
        case .endFlow:
            coordinator?.endFlow()
        case .showMeetImage:
            let meetSummary = currentState.meet?.meetSummary
            let title = meetSummary?.name
            let imagePath = meetSummary?.imagePath
            coordinator?.presentPhotoView(title: title,
                                          imagePath: imagePath)
        case .memberList:
            coordinator?.pushMemberListView()
        case .openNoticeList:
            // 확성기 버튼 → 공지 리스트 진입
            guard let meet = currentState.meet,
                  let meetId = meet.meetSummary?.id else { return .empty() }
            coordinator?.presentNoticeListView(meetId: meetId,
                                               isCreator: meet.isCreator)
        case .openNoticeDetail:
            // 미리보기 카드 → 공지 상세 진입 (pinnedNotice가 있을 때만)
            guard let meet = currentState.meet,
                  let notice = meet.pinnedNotice,
                  notice.noticeId != nil else { return .empty() }
            coordinator?.presentNoticeDetailView(notice: notice,
                                                 isCreator: meet.isCreator)
        }

        return .empty()
    }
}

// MARK: - Notify
extension MeetDetailViewReactor {
    /// 미팅 수정 알림 수신
    private func handleMeetPayload(with payload: MeetPayload) -> Observable<Mutation> {
        guard case .updated(let meet) = payload else { return .empty() }
        return .just(.setMeetInfo(meet: meet))
    }
    
    private func resetPost() -> Observable<Mutation> {
        return fetchMeetInfo()
    }
}

// MARK: - Commands
extension MeetDetailViewReactor {
    private func fetchPost() {
        planListCommands?.fetchPlan()
        reviewListCommands?.fetchReview()
    }
}

// MARK: - Delegate
extension MeetDetailViewReactor: MeetDetailDelegate {
    
    func selectedPlan(id: Int, type: PostType) {
        coordinator?.presentPlanDetailView(postId: id, type: type)
    }
    
    func refresh() {
        action.onNext(.refresh)
    }
    
    func updateLoadingMutation(_ isLoading: Bool, index: Int) {
        switch index {
        case 0:
            action.onNext(.loading(.planLoading(isLoading)))
        case 1:
            action.onNext(.loading(.reviewLoading(isLoading)))
        default:
            break
        }
    }

    func catchError(_ error: Error, index: Int) {
        switch error {
        case let error as DateTransitionError:
            action.onNext(.catchError(.midnight(error)))
        case let error as ResponseError:
            action.onNext(.catchError(.noResponse(error)))
        default:
            return
        }
    }
}

// MARK: - Child Loading
extension MeetDetailViewReactor {
    private func handleChildLoading(_ action: Action.Loading) -> Observable<Mutation> {
        switch action {
        case let .planLoading(isLoad):
            return .just(.updatePlanListLoading(isLoad))
        case let .reviewLoading(isLoad):
            return .just(.updateReviewListLoading(isLoad))
        }
    }
}

// MARK: - Loading & Error
extension MeetDetailViewReactor: LoadingReactor {
    func updateLoadingMutation(_ isLoading: Bool) -> Mutation {
        return .updateMeetInfoLoading(isLoading)
    }
    
    func catchErrorMutation(_ error: Error) -> Mutation {
        guard let dataError = error as? DataRequestError,
              let responseError = handleDataRequestError(err: dataError) else {
            return .catchError(.unknown(error))
        }
        return .catchError(.noResponse(responseError))
    }
    
    private func handleDataRequestError(err: DataRequestError) -> ResponseError? {
        return DataRequestError.resolveNoResponseError(err: err,
                                                       responseType: .meet(id: meetId))
    }
}
