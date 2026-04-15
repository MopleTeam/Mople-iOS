//
//  CommonDIContainer.swift
//  Mople
//
//  Created by CatSlave on 1/4/25.
//

import UIKit
import Domain
import Data

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
                                 defaultImageType: UIImageView.DefaultImageType) -> PhotoBookViewController
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
        #if DEV
        return MockDataManager.resolve(ImageUploadUseCase(imageUploadRepo: repo) as ImageUpload, mock: MockImageUploadUseCase())
        #else
        return ImageUploadUseCase(imageUploadRepo: repo)
        #endif
    }

    private func makeCreateMeetUseCase(repo: MeetRepo) -> CreateMeet {
        #if DEV
        return MockDataManager.resolve(CreateMeetUseCase(createMeetRepo: repo) as CreateMeet, mock: MockCreateMeetUseCase())
        #else
        return CreateMeetUseCase(createMeetRepo: repo)
        #endif
    }

    private func makeEditMeetUseCase(repo: MeetRepo) -> EditMeet {
        #if DEV
        return MockDataManager.resolve(EditMeetUseCase(repo: repo) as EditMeet, mock: MockEditMeetUseCase())
        #else
        return EditMeetUseCase(repo: repo)
        #endif
    }
    
    // MARK: - 멤버 리스트 화면
    func makeMemberListViewController(type: MemberListType,
                                      coordinator: MemberListViewCoordination) -> MemberListViewController {
        return MemberListViewController(screenName: .participant_list,
                                        title: "참여자 목록",
                                        reactor: makeMemberListViewReactor(type: type,
                                                                           coordinator: coordinator),
                                        type: type)
    }
    
    private func makeMemberListViewReactor(type: MemberListType,
                                           coordinator: MemberListViewCoordination) -> MemberListViewReactor {
        
        return .init(type: type,
                     fetchMemberUseCase: makeFetchMemberUseCase(),
                     inviteMeetUseCase: makeInviteMeetUseCase(),
                     coordinator: coordinator)
    }
    
    private func makeFetchMemberUseCase() -> FetchMemberList {
        let repo = DefaultMemberRepo(networkService: appNetworkService)
        #if DEV
        return MockDataManager.resolve(FetchMemberUseCase(memberListRepo: repo) as FetchMemberList, mock: MockFetchMemberUseCase())
        #else
        return FetchMemberUseCase(memberListRepo: repo)
        #endif
    }

    private func makeInviteMeetUseCase() -> InviteMeet {
        let repo = DefaultMeetRepo(networkService: appNetworkService)
        #if DEV
        return MockDataManager.resolve(InviteMeetUseCase(repo: repo) as InviteMeet, mock: MockInviteMeetUseCase())
        #else
        return InviteMeetUseCase(repo: repo)
        #endif
    }
    
    // MARK: - 포토뷰
    func makePhotoViewController(title: String?,
                                 imagePath: [String],
                                 defaultImageType: UIImageView.DefaultImageType) -> PhotoBookViewController {
        return .init(screenName: .photo,
                     title: title,
                     imagePaths: imagePath,
                     defaultImageType: defaultImageType)
    }
}
