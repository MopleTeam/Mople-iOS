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
        case fetchPage(keyword: String?)
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
    
    // MARK: - UseCase
    private let fetchMentionListUseCase: FetchMentionList
    
    // MARK: - LifeCycle
    init(fetchMentionListUseCase: FetchMentionList) {
        self.fetchMentionListUseCase = fetchMentionListUseCase
        initialAction()
        logLifeCycle()
    }
    
    deinit {
        logLifeCycle()
    }
    
    // MARK: - Initial Setup
    private func initialAction() {
//        action.onNext(.fetchPage(keyword: nil))
    }
    
    // MARK: - State Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .fetchPage(keyword):
            return fetchMentionList(keyword: keyword)
        case .fetchNextPage:
            return fetchMentionList()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case let .fetchedPage(list):
            newState.members.append(contentsOf: list)
        }
        
        return newState
    }
}

extension MentionListViewReactor {
    private func fetchMentionList(keyword: String? = nil) -> Observable<Mutation> {
        let cursor = page?.nextCursor
        return fetchMentionListUseCase.execute(cursor: cursor,
                                               keyword: keyword)
        .map { [weak self] in
            self?.page = $0.page
            self?.cachedResult[keyword ?? ""]?.append(contentsOf: $0.members)
            return Mutation.fetchedPage($0.members)
        }
    }
}
