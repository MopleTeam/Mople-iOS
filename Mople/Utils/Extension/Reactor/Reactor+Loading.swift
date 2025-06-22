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
        
        var isCompleted = false

        let newTask = task
            .observe(on: MainScheduler.instance)
            .do(onDispose: {
                isCompleted = true
            })
            .flatMap({ [weak self] mutation -> Observable<Mutation> in
                guard let self else { return .empty() }
                let loadingStop = self.updateLoadingMutation(false)
                return .of(mutation, loadingStop)
            })
            .catch { [weak self] error -> Observable<Mutation> in
                guard let self else { return .empty() }
                return self.catchError(error)
            }

        let loadingStart = Observable.just(())
            .delay(defferredLoadingDelay, scheduler: MainScheduler.instance)
            .flatMap { [weak self] _ -> Observable<Mutation> in
                guard let self else { return .empty() }
                return isCompleted ?
                    .empty() :
                    .just(self.updateLoadingMutation(true))
            }
        
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

