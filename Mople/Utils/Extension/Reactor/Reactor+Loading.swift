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
                            defferredLoadingDelay: RxTimeInterval = .milliseconds(300),
                            completionScheduler: ImmediateSchedulerType = MainScheduler.instance,
                            completionDealy: RxTimeInterval = .seconds(0),
                            completeMutation: Mutation? = nil,
                            completion: (() -> Void)? = nil) -> Observable<Mutation> {
                
        let newTask = task
            .catch { [weak self] error -> Observable<Mutation> in
                guard let self else { return .empty() }
                return self.catchError(error)
            }
            .concat(loadingStop(scheduler: completionScheduler,
                                delay: completionDealy,
                                completeMutation: completeMutation,
                                completion: completion))
            .share(replay: 1)
        
        let loadingStart = Observable.just(updateLoadingMutation(true))
            .delay(defferredLoadingDelay, scheduler: MainScheduler.instance)
            .take(until: newTask)
        
        return .merge([newTask, loadingStart])
    }
    
    private func catchError(_ error: Error) -> Observable<Mutation> {
        let loadingStop = updateLoadingMutation(false)
        let catchError = catchErrorMutation(error)
        return .of(loadingStop, catchError)
    }
    
    private func loadingStop(scheduler: ImmediateSchedulerType = MainScheduler.instance,
                             delay: RxTimeInterval = .seconds(0),
                             completeMutation: Mutation? = nil,
                             completion: (() -> Void)? = nil) -> Observable<Mutation> {
        return Observable.just(updateLoadingMutation(false))
            .delay(delay, scheduler: MainScheduler.instance)
            .observe(on: scheduler)
            .flatMap({ mutation -> Observable<Mutation> in
                completion?()
                if let completeMutation {
                    return .of(mutation, completeMutation)
                } else {
                    return .just(mutation)
                }
            })
    }
}

