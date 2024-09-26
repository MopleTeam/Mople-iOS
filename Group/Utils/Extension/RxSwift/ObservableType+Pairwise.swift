//
//  ObservableType+Pairwise.swift
//  Group
//
//  Created by CatSlave on 9/25/24.
//

import RxSwift

extension ObservableType {
    
    public func nwise(_ n: Int) -> Observable<[Element]> {
        return self
            .scan([]) { acc, item in Array((acc + [item]).suffix(n)) }
            .filter { $0.count == n }
    }

    public func pairwise() -> Observable<(Element, Element)> {
        return self.nwise(2)
            .map { ($0[0], $0[1]) }
    }
}
