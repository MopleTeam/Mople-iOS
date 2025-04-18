//
//  APIEndpoints.swift
//  Group
//
//  Created by CatSlave on 8/22/24.
//

import Foundation

enum HTTPHeader {
    private static let acceptAll = ["Accept": "*/*"]
    private static let acceptJson = ["Accept": "application/json"]
    private static let contentJson = ["Content-Type": "application/json"]
    
    static func getReceiveJsonHeader() -> [String:String] {
        Self.acceptJson
    }
    
    static func getReceiveAllHeader() -> [String:String] {
        Self.acceptAll
    }
    
    static func getSendAndReceiveAllHeader() -> [String:String] {
        return Self.acceptAll.merging(Self.contentJson) { current, _ in current }
    }
    
    static func getSendAndReceiveJsonHeader() -> [String:String] {
        Self.acceptJson.merging(Self.contentJson) { current, _ in current }
    }
    
    static func getMultipartFormDataHeader(_ boundary: String) -> [String:String] {
        let multiType = ["Content-Type":"multipart/form-data; boundary=\(boundary)"]
        return Self.acceptJson.merging(multiType) { current, _ in current }
    }
}

struct APIEndpoints {
    
    private static func getAccessTokenParameters() throws -> [String:String] {
        guard let token = JWTTokenStorage.cachedToken?.accessToken else { throw DataRequestError.expiredToken }
        return ["Authorization":"Bearer \(token)"]
    }
    
    private static func getRefreshTokenParameters() throws -> [String:String] {
        guard let token = JWTTokenStorage.cachedToken?.refreshToken else { throw DataRequestError.expiredToken }
        return ["refreshToken": token]
    }
}

// MARK: - FCM Token
extension APIEndpoints {
    static func uploadFCMToken(_ fcmToken: String) throws -> Endpoint<Void> {
        return try Endpoint(path: "token/save",
                            authenticationType: .accessToken,
                            method: .post,
                            headerParameters: HTTPHeader.getSendAndReceiveAllHeader(),
                            bodyParameters: ["token": fcmToken,
                                             "subscribe": true])
    }
}

// MARK: - Token Refresh
extension APIEndpoints {
    static func reissueToken() throws -> Endpoint<Data> {
        return try Endpoint(path: "auth/recreate",
                            authenticationType: .refreshToken,
                            method: .post,
                            headerParameters: HTTPHeader.getReceiveJsonHeader(),
                            responseDecoder: RawDataResponseDecoder())
    }
}

// MARK: - Login
extension APIEndpoints {
    static func executeSignUp(request: SignUpRequest) -> Endpoint<Data> {
        return try! Endpoint(path: "auth/sign-up",
                             method: .post,
                             headerParameters: HTTPHeader.getSendAndReceiveJsonHeader(),
                             bodyParametersEncodable: request,
                             responseDecoder: RawDataResponseDecoder())
    }
    
    static func executeSignIn(platform: String,
                              identityToken: String,
                              email: String) -> Endpoint<Data> {
        return try! Endpoint(path: "auth/sign-in",
                             method: .post,
                             headerParameters: HTTPHeader.getSendAndReceiveJsonHeader(),
                             bodyParameters: ["socialProvider": platform,
                                              "providerToken": identityToken,
                                              "email": email],
                             responseDecoder: RawDataResponseDecoder())
    }
    
    static func getUserInfo() throws -> Endpoint<UserInfoDTO> {
        return try Endpoint(path: "user/info",
                            authenticationType: .accessToken,
                            method: .get,
                            headerParameters: HTTPHeader.getReceiveJsonHeader())
    }
}

// MARK: - Profile
extension APIEndpoints {
    
    static func setupProfile(request: ProfileEditRequest) throws -> Endpoint<UserInfoDTO> {
        return try Endpoint(path: "user/info",
                            authenticationType: .accessToken,
                            method: .patch,
                            headerParameters: HTTPHeader.getSendAndReceiveJsonHeader(),
                            bodyParametersEncodable: request)
    }
    
    static func checkNickname(_ name: String) -> Endpoint<Data> {
        return try! Endpoint(path: "user/nickname/duplicate",
                             method: .get,
                             headerParameters: HTTPHeader.getReceiveJsonHeader(),
                             queryParameters: ["nickname":name],
                             responseDecoder: RawDataResponseDecoder())
    }
    
    static func getRandomNickname() -> Endpoint<Data> {
        return try! Endpoint(path: "user/nickname/random",
                             method: .get,
                             headerParameters: HTTPHeader.getReceiveJsonHeader(),
                             responseDecoder: RawDataResponseDecoder())
    }
}
// MARK: - 이미지 편집
extension APIEndpoints {
    static func uploadImage(imageData: Data,
                            folderPath: ImageUploadPath) -> Endpoint<String?> {
        let boundary = UUID().uuidString
        let multipartFormEncoder = MultipartBodyEncoder(boundary: boundary)
        return try! Endpoint(path: "image/upload/\(folderPath.rawValue)",
                             method: .post,
                             headerParameters: HTTPHeader.getMultipartFormDataHeader(boundary),
                             bodyParameters: ["image": imageData],
                             bodyEncoder: multipartFormEncoder)
    }
    
    static func uploadReviewImage(id: Int,
                                  imageDatas: [Data]) throws -> Endpoint<Void> {
        let boundary = UUID().uuidString
        let multipartFormEncoder = MultipartBodyEncoder(boundary: boundary)
        return try Endpoint(path: "image/review/review",
                            authenticationType: .accessToken,
                            method: .post,
                            headerParameters: HTTPHeader.getMultipartFormDataHeader(boundary),
                            bodyParameters: ["reviewId": "\(id)",
                                             "images": imageDatas],
                            bodyEncoder: multipartFormEncoder)
    }
    
    static func deleteReviewImage(reviewId: Int,
                                  imageIds: [String]) throws -> Endpoint<Void> {
        return try Endpoint(path: "review/images/\(reviewId)",
                            authenticationType: .accessToken,
                            method: .delete,
                            headerParameters: HTTPHeader.getSendAndReceiveJsonHeader(),
                            bodyParameters: ["reviewImages": imageIds]
        )
    }
}

// MARK: - 파이어베이스 토큰 저장
extension APIEndpoints {
    static func uploadToken(fcmToken: String) throws -> Endpoint<Void> {
        return try Endpoint(path: "token/save",
                            authenticationType: .accessToken,
                            method: .post,
                            headerParameters: HTTPHeader.getSendAndReceiveAllHeader(),
                            bodyParameters: ["token": fcmToken])
    }
}

// MARK: - Meet
extension APIEndpoints {
    static func createMeet(request: CreateMeetRequest) throws -> Endpoint<MeetResponse> {
        return try Endpoint(path: "meet/create",
                            authenticationType: .accessToken,
                            method: .post,
                            headerParameters: HTTPHeader.getSendAndReceiveJsonHeader(),
                            bodyParametersEncodable: request)
    }
    
    static func editMeet(id: Int,
                         request: CreateMeetRequest) throws -> Endpoint<MeetResponse> {
        return try Endpoint(path: "meet/update/\(id)",
                            authenticationType: .accessToken,
                            method: .patch,
                            headerParameters: HTTPHeader.getSendAndReceiveJsonHeader(),
                            bodyParametersEncodable: request)
    }
    
    static func fetchMeetList() throws -> Endpoint<[MeetResponse]> {
        return try Endpoint(path: "meet/list",
                            authenticationType: .accessToken,
                            method: .get,
                            headerParameters: HTTPHeader.getReceiveJsonHeader())
        
    }
    
    static func fetchMeetDetail(id: Int) throws -> Endpoint<MeetResponse> {
        return try Endpoint(path: "meet/\(id)",
                            authenticationType: .accessToken,
                            method: .get,
                            headerParameters: HTTPHeader.getReceiveJsonHeader())
    }
    
    static func deleteMeet(id: Int) throws -> Endpoint<Void> {
        return try Endpoint(path: "meet/\(id)",
                            authenticationType: .accessToken,
                            method: .delete,
                            headerParameters: HTTPHeader.getReceiveAllHeader())
    }
}

// MARK: - Plan
extension APIEndpoints {
    
    // MARK: - Fetch
    static func fetchPlan(id: Int) throws -> Endpoint<PlanResponse> {
        return try Endpoint(path: "plan/detail/\(id)",
                            authenticationType: .accessToken,
                            method: .get,
                            headerParameters: HTTPHeader.getReceiveJsonHeader())
    }
    
    static func fetchRecentPlan() throws -> Endpoint<HomeDataResponse> {
        return try Endpoint(path: "plan/view",
                            authenticationType: .accessToken,
                            method: .get,
                            headerParameters: HTTPHeader.getReceiveJsonHeader())
        
    }
    
    static func fetchMeetPlan(id: Int) throws -> Endpoint<[PlanResponse]> {
        return try Endpoint(path: "plan/list/\(id)",
                            authenticationType: .accessToken,
                            method: .get,
                            headerParameters: HTTPHeader.getReceiveJsonHeader())
        
    }
    
    // MARK: - CRUD
    static func joinPlan(id: Int) throws -> Endpoint<Void> {
        return try Endpoint(path: "plan/join/\(id)",
                            authenticationType: .accessToken,
                            method: .post,
                            headerParameters: HTTPHeader.getReceiveAllHeader())
    }
    
    static func leavePlan(id: Int) throws -> Endpoint<Void> {
        return try Endpoint(path: "plan/leave/\(id)",
                            authenticationType: .accessToken,
                            method: .delete,
                            headerParameters: HTTPHeader.getReceiveAllHeader())
    }
    
    static func createPlan(request: PlanRequest) throws -> Endpoint<PlanResponse> {
        return try Endpoint(path: "plan/create",
                            authenticationType: .accessToken,
                            method: .post,
                            headerParameters: HTTPHeader.getSendAndReceiveJsonHeader(),
                            bodyParametersEncodable: request)
    }
    
    static func editPlan(request : PlanRequest) throws -> Endpoint<PlanResponse> {
        return try Endpoint(path: "plan/update",
                            authenticationType: .accessToken,
                            method: .patch,
                            headerParameters: HTTPHeader.getSendAndReceiveJsonHeader(),
                            bodyParametersEncodable: request)
    }
    
    static func deletePlan(id: Int) throws -> Endpoint<Void> {
        return try Endpoint(path: "plan/\(id)",
                            authenticationType: .accessToken,
                            method: .delete,
                            headerParameters: HTTPHeader.getReceiveJsonHeader())
    }
}

// MARK: - Review
extension APIEndpoints {
    static func fetchMeetReview(id: Int) throws -> Endpoint<[ReviewResponse]> {
        return try Endpoint(path: "review/list/\(id)",
                            authenticationType: .accessToken,
                            method: .get,
                            headerParameters: HTTPHeader.getReceiveJsonHeader())
    }
    
    static func fetchReviewDetail(id: Int) throws -> Endpoint<ReviewResponse> {
        return try Endpoint(path: "review/\(id)",
                            authenticationType: .accessToken,
                            method: .get,
                            headerParameters: HTTPHeader.getReceiveJsonHeader())
    }
    
    static func deleteReview(id: Int) throws -> Endpoint<Void> {
        return try Endpoint(path: "review/\(id)",
                            authenticationType: .accessToken,
                            method: .delete,
                            headerParameters: HTTPHeader.getSendAndReceiveJsonHeader())
    }
}

// MARK: - Search Location
extension APIEndpoints {
    static func searchPlace(request: SearchLocationRequest) throws -> Endpoint<SearchPlaceResultResponse> {
        return try Endpoint(path: "location/kakao",
                            authenticationType: .accessToken,
                            method: .post,
                            headerParameters: HTTPHeader.getSendAndReceiveJsonHeader(),
                            bodyParametersEncodable: request)
    }
}

// MARK: - 댓글
extension APIEndpoints {
    static func fetchCommentList(id: Int) throws -> Endpoint<[CommentResponse]> {
        return try Endpoint(path: "comment/\(id)",
                            authenticationType: .accessToken,
                            method: .get,
                            headerParameters: HTTPHeader.getReceiveJsonHeader())
    }
    
    static func createComment(id: Int,
                              comment: String) throws -> Endpoint<[CommentResponse]> {
        return try Endpoint(path: "comment/\(id)",
                            authenticationType: .accessToken,
                            method: .post,
                            headerParameters: HTTPHeader.getSendAndReceiveJsonHeader(),
                            bodyParameters: ["contents": comment])
    }
    
    static func deleteComment(commentId: Int) throws -> Endpoint<Void> {
        return try Endpoint(path: "comment/\(commentId)",
                            authenticationType: .accessToken,
                            method: .delete,
                            headerParameters: HTTPHeader.getReceiveAllHeader())
    }
    
    static func editComment(postId: Int,
                            commentId: Int,
                            comment: String) throws -> Endpoint<[CommentResponse]> {
        return try Endpoint(path: "comment/\(postId)/\(commentId)",
                            authenticationType: .accessToken,
                            method: .patch,
                            headerParameters: HTTPHeader.getSendAndReceiveJsonHeader(),
                            bodyParameters: ["contents": comment])
    }
}

// MARK: - 멤버 리스트
extension APIEndpoints {
    static func fetchMember(type: MemberListType) throws -> Endpoint<MemberListResponse> { // 모델 변경
        return try Endpoint(path: getFetchMemberPath(type: type),
                            authenticationType: .accessToken,
                            method: .get,
                            headerParameters: HTTPHeader.getReceiveJsonHeader())
    }
    
    private static func getFetchMemberPath(type: MemberListType) -> String {
        switch type {
        case let .meet(id):
            return "meet/members/\(id ?? 0)"
        case let .plan(id):
            return "plan/participants/\(id ?? 0)"
        case let .review(id):
            return "review/participant/\(id ?? 0)"
        }
    }
}

// MARK: - 신고
extension APIEndpoints {
    static func report(request: ReportRequest) throws -> Endpoint<Void> {
        return try Endpoint(path: getReportPath(type: request.type),
                            authenticationType: .accessToken,
                            method: .post,
                            headerParameters: HTTPHeader.getSendAndReceiveAllHeader(),
                            bodyParametersEncodable: request)
    }
    
    private static func getReportPath(type: ReportType) -> String {
        switch type {
        case .plan:
            return "plan/report"
        case .review:
            return "review/report"
        case .comment:
            return "comment/report"
        }
    }
}

// MARK: - 캘린더
extension APIEndpoints {
    static func fetchCalendarDates() throws -> Endpoint<AllPlanDateResponse> {
        return try Endpoint(path: "plan/date",
                            authenticationType: .accessToken,
                            method: .get,
                            headerParameters: HTTPHeader.getReceiveJsonHeader())
    }
    
    static func fetchCalendarPagingData(month: String) throws -> Endpoint<MonthlyPlanResponse> {
        return try Endpoint(path: "plan/page",
                            authenticationType: .accessToken,
                            method: .get,
                            headerParameters: HTTPHeader.getReceiveJsonHeader(),
                            queryParameters: ["date":"\(month)"])
    }
}

// MARK: - 알림
extension APIEndpoints {
    static func fetchNotify() throws -> Endpoint<[NotifyResponse]> {
        return try Endpoint(path: "notification/list",
                            authenticationType: .accessToken,
                            method: .get,
                            headerParameters: HTTPHeader.getReceiveJsonHeader())
    }
}

// MARK: - 알림 구독
extension APIEndpoints {
    static func fetchNotifyState() throws -> Endpoint<[String]> {
        return try Endpoint(path: "notification/subscribe",
                            authenticationType: .accessToken,
                            method: .get,
                            headerParameters: HTTPHeader.getSendAndReceiveAllHeader())
    }
    
    static func subscribeMeetNotify(type: SubscribeType,
                                    isSubscribe: Bool) throws -> Endpoint<Void> {
        
        let path = isSubscribe ? "notification/subscribe" : "notification/unsubscribe"
        return try Endpoint(path: path,
                            authenticationType: .accessToken,
                            method: .post,
                            headerParameters: HTTPHeader.getSendAndReceiveAllHeader(),
                            bodyParameters: ["topics": ["\(type.rawValue)"]])
    }
}
