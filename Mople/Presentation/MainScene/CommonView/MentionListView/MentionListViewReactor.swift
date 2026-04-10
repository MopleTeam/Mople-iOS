//
//  MensionListViewReactor.swift
//  Mople
//
//  Created by CatSlave on 8/5/25.
//

import UIKit
import ReactorKit

final class MentionListViewReactor: Reactor, LifeCycleLoggable {
    
    enum Action {
        case fetchPage(postId: Int, keyword: String?)
        case fetchNextPage
    }
    
    enum Mutation {
        case fetchedPage([MemberInfo])
    }
    
    struct State {
        @Pulse var members: [MemberInfo] = []
    }
    
    // MARK: - Variables
    var initialState: State = State()
    private var cachedResult: [String: [MemberInfo]] = [:]
    private var page: PageInfo?
    private var postId: Int?
    private var currentKeyword: String?
    
    // MARK: - UseCase
    private let fetchMentionListUseCase: FetchMentionList
    
    // MARK: - LifeCycle
    init(fetchMentionListUseCase: FetchMentionList) {
        self.fetchMentionListUseCase = fetchMentionListUseCase
        logLifeCycle()
    }
    
    deinit {
        logLifeCycle()
    }
    
    // MARK: - State Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .fetchPage(meetId, keyword):
            return fetchMentionList(meetId: meetId,
                                    keyword: keyword,
                                    isFirst: true)
        case .fetchNextPage:
            guard let postId, let currentKeyword else { return .empty() }
            return fetchMentionList(meetId: postId,
                                    keyword: currentKeyword,
                                    isFirst: false)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case let .fetchedPage(list):
            newState.members = list
        }
        
        return newState
    }
}

extension MentionListViewReactor {
    private func fetchMentionList(meetId: Int,
                                  keyword: String? = nil,
                                  isFirst: Bool) -> Observable<Mutation> {
        if let cachedResult = cachedResult[keyword ?? ""] {
            return .just(Mutation.fetchedPage(cachedResult))
        } else {
            return Observable.create { [weak self] observer in
                let task = Task { [weak self] in
                    do {
                        let result = try await self?.fetchMentionListUseCase.execute(
                            meetId: meetId,
                            cursor: self?.page?.nextCursor,
                            keyword: keyword ?? ""
                        )
                        guard let self, let result else { return }
                        self.page = result.info
                        self.cachedResult[keyword ?? ""]?.append(contentsOf: result.content)
                        let members = isFirst ? result.content : self.appendMember(member: result.content)
                        observer.onNext(.fetchedPage(members))
                        observer.onCompleted()
                    } catch {
                        observer.onError(error)
                    }
                }
                return Disposables.create { task.cancel() }
            }
        }
    }
    
    private func appendMember(member: [MemberInfo]) -> [MemberInfo] {
        var member = currentState.members
        member.append(contentsOf: member)
        return member
    }
}
