//
//  CreateComment.swift
//  Mople
//
//  Created by CatSlave on 1/20/25.
//

import RxSwift

protocol CreateComment {
    func execute(postId: Int, content: String) -> Single<Void>
}
