//
//  ReviewSuggestionStorage.swift
//  Mople
//
//  Created by CatSlave on 6/12/26.
//

import Foundation

private enum UserDefaultsKey: String {
    case suggestedReviewPostIds
}

/// 후기 작성 추천 알럿의 노출 이력을 게시글 단위로 관리한다.
/// - 같은 후기 게시글에 다시 들어와도 알럿이 매번 뜨지 않고, 게시글마다 최초 1회만 노출되도록 한다.
public extension UserDefaults {

    /// 해당 게시글에서 후기 추천 알럿을 이미 노출했는지 여부
    static func hasSuggestedReview(postId: Int) -> Bool {
        let shownIds = UserDefaults.standard.array(forKey: UserDefaultsKey.suggestedReviewPostIds.rawValue) as? [Int] ?? []
        return shownIds.contains(postId)
    }

    /// 해당 게시글의 후기 추천 알럿 노출 이력을 기록한다.
    static func markSuggestedReview(postId: Int) {
        var shownIds = UserDefaults.standard.array(forKey: UserDefaultsKey.suggestedReviewPostIds.rawValue) as? [Int] ?? []
        guard !shownIds.contains(postId) else { return }
        shownIds.append(postId)
        UserDefaults.standard.set(shownIds, forKey: UserDefaultsKey.suggestedReviewPostIds.rawValue)
    }
}
