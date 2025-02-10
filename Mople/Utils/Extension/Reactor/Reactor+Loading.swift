//
//  Reactor+Loading.swift
//  Mople
//
//  Created by CatSlave on 2/6/25.
//

import RxSwift

protocol LoadingState {
    var isLoading: Bool { get }
}

protocol LoadingReactor: AnyObject {
    associatedtype Mutation
    var loadingState: LoadingState { get }
    func updateLoadingState(_ isLoading: Bool) -> Mutation
    func catchError(_ error: Error) -> Mutation
}

extension LoadingReactor {

    func requestWithLoading(task: Observable<Mutation>,
                            defferredLoadingDelay: RxTimeInterval = .milliseconds(300),
                            completionScheduler: ImmediateSchedulerType = MainScheduler.instance,
                            completionDealy: RxTimeInterval = .never,
                            completion: (() -> Void)? = nil) -> Observable<Mutation> {
                
        let newTask = task
            .concat(loadingStop(completion: completion))
            .catch { [weak self] error -> Observable<Mutation> in
                guard let self else { return .empty() }
                return self.catchError(error)
            }
            .share(replay: 1)
        
        let loadingStart = Observable.just(updateLoadingState(true))
            .delay(defferredLoadingDelay, scheduler: MainScheduler.instance)
            .take(until: newTask)
        
        return .merge([newTask, loadingStart])
    }
    
    private func catchError(_ error: Error) -> Observable<Mutation> {
        let loadingStop = Observable.just(updateLoadingState(false))
        let catchError = Observable.just(catchError(error))
        return .concat([loadingStop, catchError])
    }
    
    private func loadingStop(scheduler: ImmediateSchedulerType = MainScheduler.instance,
                             delay: RxTimeInterval = .seconds(0),
                             completion: (() -> Void)? = nil) -> Observable<Mutation> {
        print(#function, #line)
        return Observable.just(updateLoadingState(false))
            .delay(delay, scheduler: MainScheduler.instance)
            .observe(on: scheduler)
            .flatMap({ [weak self] mutation -> Observable<Mutation> in
                guard let self, self.loadingState.isLoading else { return .empty() }
                completion?()
                return .just(mutation)
            })
    }
}
