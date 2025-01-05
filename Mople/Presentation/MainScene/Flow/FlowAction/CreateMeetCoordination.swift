//
//  CreateFlowAction.swift
//  Mople
//
//  Created by CatSlave on 1/4/25.
//

import Foundation

protocol CreateMeetCoordination: MainCoordination {
    func completedAndSwitchMeetListTap(completion: (() -> Void)?)
}

// MARK: - 모임, 일정 생성 액션
extension MainSceneCoordinator: CreateMeetCoordination {
    /// 모임 및 일정 생성 후 모임리스트 탭으로 변경
    func completedAndSwitchMeetListTap(completion: (() -> Void)?) {
        self.switchTap(route: .group)
        self.closeSubView(completion: {
            completion?()
        })
    }
}
