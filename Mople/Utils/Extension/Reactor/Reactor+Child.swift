//
//  Reactor+Child.swift
//  Mople
//
//  Created by CatSlave on 2/18/25.
//

import RxSwift
import Domain

protocol ChildLoadingDelegate: AnyObject {
    func updateLoadingMutation(_ isLoading: Bool, index: Int)
    func catchError(_ error: Error, index: Int)
}

protocol ChildLoadingReactor: AnyObject {
    associatedtype Mutation
    func updateLoadingState(isLoad: Bool)
    var parent: ChildLoadingDelegate? { get }
    var index: Int { get }
}

extension ChildLoadingReactor {
    
    var index: Int { 0 }
    
    func updateLoadingState(isLoad: Bool) {
        
    }

    func requestWithLoading(task: Observable<Mutation>,
                            defferredLoadingDelay: RxTimeInterval = .milliseconds(0)
    ) -> Observable<Mutation> {
        
        var isCompleted = false
        
        let newTask = task
            .do(onDispose: { [weak self] in
                isCompleted = true
                let index = self?.index ?? 0
                self?.parent?.updateLoadingMutation(false, index: index)
            })
            .catch { [weak self] error -> Observable<Mutation> in
                guard let self else { return .empty() }
                return self.catchError(error)
            }
        
        let loadingStart = Observable.just(())
            .do(onSubscribe: {
                self.updateLoadingState(isLoad: true)
            })
            .delay(defferredLoadingDelay, scheduler: MainScheduler.instance)
            .flatMap({ [weak self] _ -> Observable<Mutation> in
                if let self,
                   !isCompleted {
                    parent?.updateLoadingMutation(true, index: index)
                }
                return .empty()
            })
            
        return .merge([loadingStart, newTask])
            .do(onDispose: {
                self.updateLoadingState(isLoad: false)
            })
    }
    
    private func catchError(_ error: Error) -> Observable<Mutation> {
        if DataRequestError.isHandledError(err: error) == false {
            parent?.catchError(error, index: index)
        }
        return .empty()
    }
}
