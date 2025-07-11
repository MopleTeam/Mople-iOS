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
    
    var index: Int { 0 }

    func requestWithLoading(task: Observable<Mutation>,
                            defferredLoadingDelay: RxTimeInterval = .milliseconds(0)
    ) -> Observable<Mutation> {
        
        var isCompleted = false
        
        let newTask = task
            .do(onDispose: { [weak self] in
                isCompleted = true
                let index = self?.index ?? 0
                self?.parent?.updateLoadingState(false, index: index)
            })
            .catch { [weak self] error -> Observable<Mutation> in
                guard let self else { return .empty() }
                return self.catchError(error)
            }
        
        let loadingStart = Observable.just(())
            .delay(defferredLoadingDelay, scheduler: MainScheduler.instance)
            .flatMap({ [weak self] _ -> Observable<Mutation> in
                if let self,
                   !isCompleted {
                    parent?.updateLoadingState(true, index: index)
                }
                return .empty()
            })
            
        return .merge([loadingStart, newTask])
    }
    
    private func catchError(_ error: Error) -> Observable<Mutation> {
        if DataRequestError.isHandledError(err: error) == false {
            parent?.catchError(error, index: index)
        }
        return .empty()
    }
}
