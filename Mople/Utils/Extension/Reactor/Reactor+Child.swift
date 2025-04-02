//
//  Reactor+Child.swift
//  Mople
//
//  Created by CatSlave on 2/18/25.
//

import RxSwift

protocol ChildLoadingDelegate {
    func updateLoadingState(_ isLoading: Bool, index: Int)
    func catchError(_ error: Error, index: Int)
}

protocol ChildLoadingReactor: AnyObject {
    associatedtype Mutation
    var parent: ChildLoadingDelegate? { get }
    var index: Int { get }
}

extension ChildLoadingReactor {
    
    var index: Int { 1 }

    func requestWithLoading(task: Observable<Mutation>,
                            minimumExecutionTime: RxTimeInterval = .seconds(0),
                            defferredLoadingDelay: RxTimeInterval = .milliseconds(0),
                            completionHandler: (() -> Void)? = nil
    ) -> Observable<Mutation> {
        let executionTimer = Observable<Int>.timer(minimumExecutionTime, scheduler: MainScheduler.instance)
        
        let loadingStop = Observable.just(())
            .flatMap { [weak self] _ -> Observable<Mutation> in
                guard let self else { return .empty() }
                completionHandler?()
                parent?.updateLoadingState(false, index: index)
                return .empty()
            }
                
        let newTask = Observable.zip(task, executionTimer)
            .map { $0.0 }
            .catch { [weak self] error -> Observable<Mutation> in
                guard let self else { return .empty() }
                return self.catchError(error)
            }
            .concat(loadingStop)
            .share(replay: 1)
        
        let loadingStart = Observable.just(())
            .delay(defferredLoadingDelay, scheduler: MainScheduler.instance)
            .take(until: newTask)
            .flatMap({ [weak self] _ -> Observable<Mutation> in
                guard let self else { return .empty() }
                parent?.updateLoadingState(true, index: index)
                return .empty()
            })
            
        return .merge([loadingStart, newTask])
    }
    
    private func catchError(_ error: Error) -> Observable<Mutation> {
        parent?.updateLoadingState(false, index: index)
        parent?.catchError(error, index: index)
        return .empty()
    }
}
