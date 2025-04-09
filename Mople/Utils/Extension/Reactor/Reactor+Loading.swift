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
                            minimumExecutionTime: RxTimeInterval = .seconds(0),
                            defferredLoadingDelay: RxTimeInterval = .milliseconds(300)
    ) -> Observable<Mutation> {
        
        let executionTimer = Observable<Int>.timer(minimumExecutionTime, scheduler: MainScheduler.instance)
        
        let loadingStop = Observable.just(updateLoadingMutation(false))
        
        let newTask = Observable.zip(task, executionTimer)
            .map { $0.0 }
            .observe(on: MainScheduler.instance)
            .catch { [weak self] error -> Observable<Mutation> in
                guard let self else { return .empty() }
                return self.catchError(error)
            }
            .concat(loadingStop)
            .share(replay: 1)

        let loadingStart = Observable.just(updateLoadingMutation(true))
            .delay(defferredLoadingDelay, scheduler: MainScheduler.instance)
            .take(until: newTask)
        
        return .merge([newTask, loadingStart])
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


