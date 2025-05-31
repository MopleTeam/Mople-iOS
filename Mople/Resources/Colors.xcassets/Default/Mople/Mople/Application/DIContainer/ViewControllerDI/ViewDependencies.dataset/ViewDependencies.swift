//
//  CommonDIContainer.swift
//  Mople
//
//  Created by CatSlave on 1/4/25.
//

import UIKit

protocol ViewDependencies {
    // MARK: - View
    func makeMemberListViewController(type: MemberListType,
                                      coordinator: MemberListViewCoordination) -> MemberListViewController
    func makeCreateMeetViewController(isFlow: Bool,
                                      isEdit: Bool,
                                      type: MeetCreationType,
                                      coordinator: MeetCreateViewCoordination) -> CreateMeetViewController
    func makePhotoViewController(title: String?,
                                 imagePath: [String],
                                 defaultImageType: UIImageView.DefaultImageType,
                                 coordinator: NavigationCloseable) -> PhotoBookViewController
}

final class ViewDIContainer: ViewDependencies {
    
    private let appNetworkService: AppNetworkService
    
    init(appNetworkService: AppNetworkService) {
        self.appNetworkService = appNetworkService
    }
}

extension ViewDIContainer {
    
    // MARK: - 그룹 생성 화면
    func makeCreateMeetViewController(isFlow: Bool,
                                      isEdit: Bool,
                                      type: MeetCreationType,
                                      coordinator: MeetCreateViewCoordination) -> CreateMeetViewController {
        return CreateMeetViewController(screenName: .meet_write,
                                        title: getCreateMeetViewTitle(type: type),
                                        isFlow: isFlow,
                                        isEdit: isEdit,
                                        reactor: makeCreateMeetViewReactor(type: type,
                                                                           coordinator: coordinator))
    }
    
    private func getCreateMeetViewTitle(type: MeetCreationType) -> String {
        switch type {
        case .create:
            return L10n.createMeet
        case .edit:
            return L10n.editMeet
        }
    }
    
    private func makeCreateMeetViewReactor(type: MeetCreationType,
                                           coordinator: MeetCreateViewCoordination) -> CreateMeetViewReactor {
        let imageUploadRepo = DefaultImageUploadRepo(networkService: appNetworkService)
        let meetRepo = DefaultMeetRepo(networkService: appNetworkService)
        return .init(type: type,
                     createMeetUseCase: makeCreateMeetUseCase(repo: meetRepo),
                     editMeetUseCase: makeEditMeetUseCase(repo: meetRepo),
                     imageUploadUseCase: makeImageUploadUseCase(repo: imageUploadRepo),
                     photoService: DefaultPhotoService(),
                     coordinator: coordinator)
    }
    
    private func makeImageUploadUseCase(repo: ImageUploadRepo) -> ImageUpload {
        return ImageUploadUseCase(imageUploadRepo: repo)
    }
    
    private func makeCreateMeetUseCase(repo: MeetRepo) -> CreateMeet {
        return CreateMeetUseCase(createMeetRepo: repo)
    }
    
    private func makeEditMeetUseCase(repo: MeetRepo) -> EditMeet {
        return EditMeetUseCase(repo: repo)
    }
    
    // MARK: - 멤버 리스트 화면
    func makeMemberListViewController(type: MemberListType,
                                      coordinator: MemberListViewCoordination) -> MemberListViewController {
        return MemberListViewController(screenName: .participant_list,
                                        title: "참여자 목록",
                                        reactor: makeMemberListViewReactor(type: type,
                                                                           coordinator: coordinator))
    }
    
    private func makeMemberListViewReactor(type: MemberListType,
                                           coordinator: MemberListViewCoordination) -> MemberListViewReactor {
        let memberRepo = DefaultMemberRepo(networkService: appNetworkService)
        return .init(type: type,
                     fetchMemberUseCase: makeFetchMemberUseCase(repo: memberRepo),
                     coordinator: coordinator)
    }
    
    private func makeFetchMemberUseCase(repo: MemberRepo) -> FetchMemberList {
        return FetchMemberUseCase(memberListRepo: repo)
    }
    
    // MARK: - 포토뷰
    func makePhotoViewController(title: String?,
                                 imagePath: [String],
                                 defaultImageType: UIImageView.DefaultImageType,
                                 coordinator: NavigationCloseable) -> PhotoBookViewController {
        return .init(screenName: .photo,
                     title: title,
                     imagePaths: imagePath,
                     defaultImageType: defaultImageType,
                     coordinator: coordinator)
    }
}
