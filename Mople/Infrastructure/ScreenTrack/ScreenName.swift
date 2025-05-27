//
//  ScreenName.swift
//  Mople
//
//  Created by CatSlave on 5/2/25.
//

import Foundation

enum ScreenName: String {
    // MARK: - Splash
    case splash

    // MARK: - Auth
    case sign_in
    case sign_up

    // MARK: - Main Tab
    case home
    case meet_list
    case calendar
    case profile

    // MARK: - Meet
    case meet_write
    case meet_detail
    case meet_setting

    // MARK: - Plan
    case plan_write
    case plan_write_map
    case plan_write_map_search
    case plan_detail

    // MARK: - Review
    case review_write
    case review_detail
    case review_image

    // MARK: - Notification
    case notification
    case notification_setting

    // MARK: - Member
    case participant_list

    // MARK: - Profile
    case profile_write
    case profile_image

    // MARK: - Policy
    case privacy_policy

    // MARK: - Map
    case map_detail
    
    // MARK: - Photo
    case photo
}
