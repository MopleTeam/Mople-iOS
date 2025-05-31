//
//  Reactor+Loading.swift
//  Mople
//
//  Created by CatSlave on 2/6/25.
//

import RxSwift

protocol LoadingReactor: AnyObject {
    associatedtype Mutation
    func updateLoadingMutation(_ isLoading: Bool) -> Mutation
    func catchErrorMutation(_ error: Error) -> Mutation
}

extension LoadingReactor {

    func requestWithLoading(task: Observable<Mutation>,
                            defferredLoadingDelay: RxTimeInterval = .milliseconds(300)
    ) -> Observable<Mutation> {
        
        let loadingStop = Observable.just(updateLoadingMutation(false))
        
        let newTask = task
            .concat(loadingStop)
            .observe(on: MainScheduler.instance)
            .catch { [weak self] error -> Observable<Mutation> in
                guard let self else { return .empty() }
                return self.catchError(error)
            }
            .share(replay: 1)

        let loadingStart = Observable.just(updateLoadingMutation(true))
            .delay(defferredLoadingDelay, scheduler: MainScheduler.instance)
            .take(until: newTask)
        
        return .merge([loadingStart, newTask])
    }
    
    private func catchError(_ error: Error) -> Observable<Mutation> {
        let loadingStop = updateLoadingMutation(false)
        
        if DataRequestError.isHandledError(err: error) {
            return .just(loadingStop)
        } else {
            let catchError = catchErrorMutation(error)
            return .of(loadingStop, catchError)
        }
    }
}

