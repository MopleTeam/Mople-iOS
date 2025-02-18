//
//  Reactor+Child.swift
//  Mople
//
//  Created by CatSlave on 2/18/25.
//

import RxSwift

protocol ChildLoadingDelegate {
    func updateLoadingState(_ isLoading: Bool)
    func catchError(_ error: Error)
}

protocol ChildLoadingReactor: AnyObject {
    associatedtype Mutation
    var parent: ChildLoadingDelegate? { get }
}

extension ChildLoadingReactor {

    func requestWithLoading(task: Observable<Mutation>,
                            defferredLoadingDelay: RxTimeInterval = .milliseconds(300),
                            completionScheduler: ImmediateSchedulerType = MainScheduler.instance,
                            completionDealy: RxTimeInterval = .never,
                            completeMutation: Mutation? = nil,
                            completion: (() -> Void)? = nil) -> Observable<Mutation> {
                
        let newTask = task
            .catch { [weak self] error -> Observable<Mutation> in
                guard let self else { return .empty() }
                return self.catchError(error)
            }
            .concat(loadingStop(scheduler: completionScheduler,
                                delay: completionDealy,
                                mutation: completeMutation,
                                completion: completion))
            .share(replay: 1)
        
        let loadingStart = Observable.just(())
            .delay(defferredLoadingDelay, scheduler: MainScheduler.instance)
            .flatMap({ [weak self] _ -> Observable<Mutation> in
                self?.parent?.updateLoadingState(true)
                return .empty()
            })
            .take(until: newTask)
        
        return .merge([newTask, loadingStart])
    }
    
    private func catchError(_ error: Error) -> Observable<Mutation> {
        parent?.updateLoadingState(false)
        parent?.catchError(error)
        return .empty()
    }
    
    private func loadingStop(scheduler: ImmediateSchedulerType = MainScheduler.instance,
                             delay: RxTimeInterval = .seconds(0),
                             mutation: Mutation? = nil,
                             completion: (() -> Void)? = nil) -> Observable<Mutation> {
        print(#function, #line)
        return Observable.just(())
            .do(onNext: { _ in
                completion?()
            })
            .delay(delay, scheduler: MainScheduler.instance)
            .observe(on: scheduler)
            .flatMap({ [weak self] _ -> Observable<Mutation> in
                self?.parent?.updateLoadingState(false)
                if let mutation {
                    return .just(mutation)
                } else {
                    return .empty()
                }
            })
    }
}
