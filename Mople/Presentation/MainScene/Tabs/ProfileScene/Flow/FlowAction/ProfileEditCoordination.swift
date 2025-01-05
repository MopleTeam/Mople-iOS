//
//  ProfileEditCoordination.swift
//  Mople
//
//  Created by CatSlave on 1/5/25.
//

import Foundation

protocol ProfileEditCoordination: AnyObject {
    func editCompleted()
    func endProcess()
}

extension ProfileSceneCoordinator: ProfileEditCoordination {
    func editCompleted() {
        self.profileVC?.fetchProfile()
        self.endProcess()
    }
    
    func endProcess() {
        self.navigationController.dismiss(animated: false)
    }
}
