// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  /// Localizable.strings
  ///   Mople
  /// 
  ///   Created by CatSlave on 5/6/25.
  internal static let appSubTitle = L10n.tr("Localizable", "app_subTitle", fallback: "모임부터 약속까지 간편한 관리")
  /// 일정관리
  internal static let calendar = L10n.tr("Localizable", "calendar", fallback: "일정관리")
  /// 취소
  internal static let cancle = L10n.tr("Localizable", "cancle", fallback: "취소")
  /// 확인
  internal static let check = L10n.tr("Localizable", "check", fallback: "확인")
  /// 댓글
  internal static let comment = L10n.tr("Localizable", "comment", fallback: "댓글")
  /// 완료
  internal static let complete = L10n.tr("Localizable", "complete", fallback: "완료")
  /// 생성하기
  internal static let create = L10n.tr("Localizable", "create", fallback: "생성하기")
  /// 모임 생성하기
  internal static let createMeet = L10n.tr("Localizable", "create_meet", fallback: "모임 생성하기")
  /// 일정 생성
  internal static let createPlan = L10n.tr("Localizable", "create_plan", fallback: "일정 생성")
  /// 모임 정보 수정
  internal static let editMeet = L10n.tr("Localizable", "edit_meet", fallback: "모임 정보 수정")
  /// 일정 수정
  internal static let editPlan = L10n.tr("Localizable", "edit_plan", fallback: "일정 수정")
  /// 프로필 수정
  internal static let editProfile = L10n.tr("Localizable", "edit_profile", fallback: "프로필 수정")
  /// 홈
  internal static let home = L10n.tr("Localizable", "home", fallback: "홈")
  /// %d개
  internal static func itemCount(_ p1: Int) -> String {
    return L10n.tr("Localizable", "item_count", p1, fallback: "%d개")
  }
  /// 모임
  internal static let meetlist = L10n.tr("Localizable", "meetlist", fallback: "모임")
  /// 참여자 목록
  internal static let memberList = L10n.tr("Localizable", "member_list", fallback: "참여자 목록")
  /// 아니오
  internal static let no = L10n.tr("Localizable", "no", fallback: "아니오")
  /// 이름 없음
  internal static let nonName = L10n.tr("Localizable", "non_name", fallback: "이름 없음")
  /// 알림
  internal static let notifylist = L10n.tr("Localizable", "notifylist", fallback: "알림")
  /// %d명 참여
  internal static func participantCount(_ p1: Int) -> String {
    return L10n.tr("Localizable", "participant_count", p1, fallback: "%d명 참여")
  }
  /// %d명
  internal static func peopleCount(_ p1: Int) -> String {
    return L10n.tr("Localizable", "people_count", p1, fallback: "%d명")
  }
  /// 상세 지도
  internal static let placedetail = L10n.tr("Localizable", "placedetail", fallback: "상세 지도")
  /// 프로필
  internal static let profile = L10n.tr("Localizable", "profile", fallback: "프로필")
  /// 저장
  internal static let save = L10n.tr("Localizable", "save", fallback: "저장")
  /// 검색
  internal static let search = L10n.tr("Localizable", "search", fallback: "검색")
  /// 설정
  internal static let setup = L10n.tr("Localizable", "setup", fallback: "설정")
  /// 예
  internal static let yes = L10n.tr("Localizable", "yes", fallback: "예")
  internal enum Calendar {
    /// 새로운 일정을 추가해주세요
    internal static let empty = L10n.tr("Localizable", "calendar.empty", fallback: "새로운 일정을 추가해주세요")
    /// %@년 %@월
    internal static func header(_ p1: Any, _ p2: Any) -> String {
      return L10n.tr("Localizable", "calendar.header", String(describing: p1), String(describing: p2), fallback: "%@년 %@월")
    }
  }
  internal enum Comment {
    /// 댓글 삭제
    internal static let delete = L10n.tr("Localizable", "comment.delete", fallback: "댓글 삭제")
    /// 댓글 수정
    internal static let edit = L10n.tr("Localizable", "comment.edit", fallback: "댓글 수정")
    /// 댓글을 입력해주세요.
    internal static let input = L10n.tr("Localizable", "comment.input", fallback: "댓글을 입력해주세요.")
  }
  internal enum CreateProfile {
    /// 모플 시작하기
    internal static let complete = L10n.tr("Localizable", "create_profile.complete", fallback: "모플 시작하기")
    /// 자신을 나타낼
    /// 프로필을 설정해주세요
    internal static let header = L10n.tr("Localizable", "create_profile.header", fallback: "자신을 나타낼\n프로필을 설정해주세요")
    /// 닉네임
    internal static let input = L10n.tr("Localizable", "create_profile.input", fallback: "닉네임")
    /// 닉네임을 입력해주세요
    internal static let inputPlaceholder = L10n.tr("Localizable", "create_profile.input_placeholder", fallback: "닉네임을 입력해주세요")
    /// 사용 가능한 닉네임 입니다.
    internal static let nameAvailable = L10n.tr("Localizable", "create_profile.name_available", fallback: "사용 가능한 닉네임 입니다.")
    /// 중복확인
    internal static let nameCheck = L10n.tr("Localizable", "create_profile.name_check", fallback: "중복확인")
    /// 이미 사용중인 닉네임 입니다.
    internal static let nameDuplicate = L10n.tr("Localizable", "create_profile.name_duplicate", fallback: "이미 사용중인 닉네임 입니다.")
  }
  internal enum Createmeet {
    /// 모임 이름
    internal static let input = L10n.tr("Localizable", "createmeet.input", fallback: "모임 이름")
    /// 모임 이름을 입력해주세요
    internal static let inputPlaceholder = L10n.tr("Localizable", "createmeet.input_placeholder", fallback: "모임 이름을 입력해주세요")
  }
  internal enum Createplan {
    /// 날짜 선택
    internal static let dateInput = L10n.tr("Localizable", "createplan.date_input", fallback: "날짜 선택")
    /// 날짜를 선택해주세요
    internal static let datePlaceholder = L10n.tr("Localizable", "createplan.date_placeholder", fallback: "날짜를 선택해주세요")
    /// 선택된 시간이 너무 이릅니다.
    internal static let invaildDate = L10n.tr("Localizable", "createplan.invaild_date", fallback: "선택된 시간이 너무 이릅니다.")
    /// 모임 이름
    internal static let meetInput = L10n.tr("Localizable", "createplan.meet_input", fallback: "모임 이름")
    /// 모임을 선택해주세요
    internal static let meetPlaceholder = L10n.tr("Localizable", "createplan.meet_placeholder", fallback: "모임을 선택해주세요")
    /// 약속 이름
    internal static let nameInput = L10n.tr("Localizable", "createplan.name_input", fallback: "약속 이름")
    /// 일정을 입력해주세요
    internal static let namePlaceholder = L10n.tr("Localizable", "createplan.name_placeholder", fallback: "일정을 입력해주세요")
    /// 장소 선택
    internal static let placeInput = L10n.tr("Localizable", "createplan.place_input", fallback: "장소 선택")
    /// 장소를 선택해주세요
    internal static let placePlaceholder = L10n.tr("Localizable", "createplan.place_placeholder", fallback: "장소를 선택해주세요")
    /// 시간 선택
    internal static let timeInput = L10n.tr("Localizable", "createplan.time_input", fallback: "시간 선택")
    /// 시간을 선택해주세요
    internal static let timePlaceholder = L10n.tr("Localizable", "createplan.time_placeholder", fallback: "시간을 선택해주세요")
  }
  internal enum Createreview {
    /// 후기 작성하기
    internal static let complete = L10n.tr("Localizable", "createreview.complete", fallback: "후기 작성하기")
    /// 만족스러운 약속이셨나요?
    /// 사진을 남겨 추억을 나눠보세요
    internal static let header = L10n.tr("Localizable", "createreview.header", fallback: "만족스러운 약속이셨나요?\n사진을 남겨 추억을 나눠보세요")
  }
  internal enum Date {
    /// D-%d
    internal static func dday(_ p1: Int) -> String {
      return L10n.tr("Localizable", "date.Dday", p1, fallback: "D-%d")
    }
    /// 오늘
    internal static let today = L10n.tr("Localizable", "date.today", fallback: "오늘")
    internal enum Duration {
      /// 전
      internal static let ago = L10n.tr("Localizable", "date.duration.ago", fallback: "전")
      /// 1초 전
      internal static let agoDefaul = L10n.tr("Localizable", "date.duration.ago_defaul", fallback: "1초 전")
    }
    internal enum Format {
      /// yyyy년 MM월 dd일
      internal static let basic = L10n.tr("Localizable", "date.format.basic", fallback: "yyyy년 MM월 dd일")
      /// yyyy. MM. dd E
      internal static let dot = L10n.tr("Localizable", "date.format.dot", fallback: "yyyy. MM. dd E")
      /// yyyy.MM.dd E HH시 mm분
      internal static let full = L10n.tr("Localizable", "date.format.full", fallback: "yyyy.MM.dd E HH시 mm분")
      /// yyyyMM
      internal static let month = L10n.tr("Localizable", "date.format.month", fallback: "yyyyMM")
      /// yyyy-MM-dd HH:mm:ss
      internal static let serverFull = L10n.tr("Localizable", "date.format.serverFull", fallback: "yyyy-MM-dd HH:mm:ss")
      /// yyyy-MM-dd
      internal static let serverSimple = L10n.tr("Localizable", "date.format.serverSimple", fallback: "yyyy-MM-dd")
      /// HH시 mm분
      internal static let time = L10n.tr("Localizable", "date.format.time", fallback: "HH시 mm분")
    }
    internal enum Label {
      /// 일
      internal static let day = L10n.tr("Localizable", "date.label.day", fallback: "일")
      /// 시간
      internal static let hour = L10n.tr("Localizable", "date.label.hour", fallback: "시간")
      /// 시
      internal static let hourShort = L10n.tr("Localizable", "date.label.hour_short", fallback: "시")
      /// 분
      internal static let minute = L10n.tr("Localizable", "date.label.minute", fallback: "분")
      /// 개월
      internal static let month = L10n.tr("Localizable", "date.label.month", fallback: "개월")
      /// 월
      internal static let monthShort = L10n.tr("Localizable", "date.label.month_short", fallback: "월")
      /// 초
      internal static let second = L10n.tr("Localizable", "date.label.second", fallback: "초")
      /// 년
      internal static let year = L10n.tr("Localizable", "date.label.year", fallback: "년")
    }
    internal enum Period {
      /// 오전
      internal static let am = L10n.tr("Localizable", "date.period.am", fallback: "오전")
      /// 오후
      internal static let pm = L10n.tr("Localizable", "date.period.pm", fallback: "오후")
    }
  }
  internal enum Error {
    /// 요청에 실패했습니다.
    /// 잠시 후 다시 시도해주세요.
    internal static let `default` = L10n.tr("Localizable", "error.default", fallback: "요청에 실패했습니다.\n잠시 후 다시 시도해주세요.")
    /// 네트워크 연결을 확인해주세요.
    internal static let network = L10n.tr("Localizable", "error.network", fallback: "네트워크 연결을 확인해주세요.")
    internal enum ExpriedToken {
      /// 로그인이 만료되었어요
      internal static let info = L10n.tr("Localizable", "error.expried_token.info", fallback: "로그인이 만료되었어요")
      /// 서비스 이용을 위해 다시 로그인해주세요
      internal static let subinfo = L10n.tr("Localizable", "error.expried_token.subinfo", fallback: "서비스 이용을 위해 다시 로그인해주세요")
    }
    internal enum Login {
      /// 설정에서 Apple 로그인 연동 해제 후
      /// 다시 시도해 주세요.
      internal static let apple = L10n.tr("Localizable", "error.login.apple", fallback: "설정에서 Apple 로그인 연동 해제 후\n다시 시도해 주세요.")
      /// 로그인에 실패했어요.
      /// 다시 시도해 주세요.
      internal static let `default` = L10n.tr("Localizable", "error.login.default", fallback: "로그인에 실패했어요.\n다시 시도해 주세요.")
      /// 카카오 계정과 연동을 실패했습니다.
      /// 다시 시도해 주세요.
      internal static let kakao = L10n.tr("Localizable", "error.login.kakao", fallback: "카카오 계정과 연동을 실패했습니다.\n다시 시도해 주세요.")
    }
    internal enum Midnight {
      /// 자정을 지나 데이터가 업데이트됐어요!
      internal static let info = L10n.tr("Localizable", "error.midnight.info", fallback: "자정을 지나 데이터가 업데이트됐어요!")
      /// 일정이 마감됐어요.
      /// 후기에서 확인해보세요.
      internal static let subinfo = L10n.tr("Localizable", "error.midnight.subinfo", fallback: "일정이 마감됐어요.\n후기에서 확인해보세요.")
    }
    internal enum NoResponse {
      /// 모임을 찾을 수 없어요.
      internal static let meet = L10n.tr("Localizable", "error.noResponse.meet", fallback: "모임을 찾을 수 없어요.")
      /// 일정을 찾을 수 없어요.
      internal static let plan = L10n.tr("Localizable", "error.noResponse.plan", fallback: "일정을 찾을 수 없어요.")
      /// 후기를 찾을 수 없어요.
      internal static let review = L10n.tr("Localizable", "error.noResponse.review", fallback: "후기를 찾을 수 없어요.")
    }
    internal enum Photo {
      /// 추가된 사진 중 %@번째 사진의 용량이 너무 커요.
      internal static func mutipleCompression(_ p1: Any) -> String {
        return L10n.tr("Localizable", "error.photo.mutiple_compression", String(describing: p1), fallback: "추가된 사진 중 %@번째 사진의 용량이 너무 커요.")
      }
      /// 선택된 사진의 용량이 너무 커요.
      internal static let singleCompression = L10n.tr("Localizable", "error.photo.single_compression", fallback: "선택된 사진의 용량이 너무 커요.")
      /// 사진을 업로드할 수 없어요.
      internal static let upload = L10n.tr("Localizable", "error.photo.upload", fallback: "사진을 업로드할 수 없어요.")
    }
    internal enum Server {
      /// 서버와 소통이 원활하지 않습니다.
      internal static let info = L10n.tr("Localizable", "error.server.info", fallback: "서버와 소통이 원활하지 않습니다.")
      /// 현재 서버와의 연결이 원활하지 않습니다.
      /// 잠시 후 다시 시도해 주세요.
      internal static let subinfo = L10n.tr("Localizable", "error.server.subinfo", fallback: "현재 서버와의 연결이 원활하지 않습니다.\n잠시 후 다시 시도해 주세요.")
    }
  }
  internal enum Home {
    /// 새로운
    /// 모임 만들기
    internal static let createMeet = L10n.tr("Localizable", "home.create_meet", fallback: "새로운\n모임 만들기")
    /// 새로운
    /// 일정 만들기
    internal static let createPlan = L10n.tr("Localizable", "home.create_plan", fallback: "새로운\n일정 만들기")
    /// 아직 소속된 모임이 없어요
    internal static let emptyMeetInfo = L10n.tr("Localizable", "home.empty_meet_info", fallback: "아직 소속된 모임이 없어요")
    /// 먼저 모임을 가입또는 생성해서 일정을 추가해보세요!
    internal static let emptyMeetSubinfo = L10n.tr("Localizable", "home.empty_meet_subinfo", fallback: "먼저 모임을 가입또는 생성해서 일정을 추가해보세요!")
    /// 새로운 일정을 추가하고
    /// 관리해보세요
    internal static let emptyPlan = L10n.tr("Localizable", "home.empty_plan", fallback: "새로운 일정을 추가하고\n관리해보세요")
    /// 더보기
    internal static let morePlan = L10n.tr("Localizable", "home.more_plan", fallback: "더보기")
  }
  internal enum Login {
    /// Apple로 시작하기
    internal static let apple = L10n.tr("Localizable", "login.apple", fallback: "Apple로 시작하기")
    /// 카카오로 시작하기
    internal static let kakao = L10n.tr("Localizable", "login.kakao", fallback: "카카오로 시작하기")
  }
  internal enum Meetdetail {
    /// 모임 삭제
    internal static let delete = L10n.tr("Localizable", "meetdetail.delete", fallback: "모임 삭제")
    /// 모임을 삭제하시겠어요?
    internal static let deleteInfo = L10n.tr("Localizable", "meetdetail.delete_info", fallback: "모임을 삭제하시겠어요?")
    /// 해당 모임에 대한 모든 기록을 복구할 수 없어요
    internal static let deleteSubinfo = L10n.tr("Localizable", "meetdetail.delete_subinfo", fallback: "해당 모임에 대한 모든 기록을 복구할 수 없어요")
    /// 새로운 일정을 추가해주세요
    internal static let emptyPost = L10n.tr("Localizable", "meetdetail.empty_post", fallback: "새로운 일정을 추가해주세요")
    /// 모플에서 초대된 모임을 확인해보세요!
    internal static let invite = L10n.tr("Localizable", "meetdetail.invite", fallback: "모플에서 초대된 모임을 확인해보세요!")
    /// 모임 나가기
    internal static let leave = L10n.tr("Localizable", "meetdetail.leave", fallback: "모임 나가기")
    /// 모임을 나가시겠어요?
    internal static let leaveInfo = L10n.tr("Localizable", "meetdetail.leave_info", fallback: "모임을 나가시겠어요?")
    /// 해당 약속은 마감되었어요
    internal static let planEnd = L10n.tr("Localizable", "meetdetail.plan_end", fallback: "해당 약속은 마감되었어요")
    /// 약속 참여하기
    internal static let planJoin = L10n.tr("Localizable", "meetdetail.Plan_join", fallback: "약속 참여하기")
    /// 약속 불참
    internal static let planLeave = L10n.tr("Localizable", "meetdetail.plan_leave", fallback: "약속 불참")
    /// 예정된 약속
    internal static let planlist = L10n.tr("Localizable", "meetdetail.planlist", fallback: "예정된 약속")
    /// 지난 약속
    internal static let reviwelist = L10n.tr("Localizable", "meetdetail.reviwelist", fallback: "지난 약속")
    /// 모임 설정
    internal static let setup = L10n.tr("Localizable", "meetdetail.setup", fallback: "모임 설정")
    /// 우리가 추억을 쌓은지 %d 일째
    internal static func sinceCount(_ p1: Int) -> String {
      return L10n.tr("Localizable", "meetdetail.since_count", p1, fallback: "우리가 추억을 쌓은지 %d 일째")
    }
  }
  internal enum Meetlist {
    /// 새로운 모임을 추가해주세요
    internal static let empty = L10n.tr("Localizable", "meetlist.empty", fallback: "새로운 모임을 추가해주세요")
    /// 약속된 일정이 있어요.
    internal static let hasPlan = L10n.tr("Localizable", "meetlist.has_plan", fallback: "약속된 일정이 있어요.")
    /// 마지막 약속으로부터 %d일 지났어요.
    internal static func lastDay(_ p1: Int) -> String {
      return L10n.tr("Localizable", "meetlist.last_day", p1, fallback: "마지막 약속으로부터 %d일 지났어요.")
    }
    /// 새로운 일정을 추가해보세요.
    internal static let newPlan = L10n.tr("Localizable", "meetlist.new_plan", fallback: "새로운 일정을 추가해보세요.")
  }
  internal enum Notify {
    /// 알람을 활성화하고  일정관리에 도움을 받아보세요
    internal static let active = L10n.tr("Localizable", "notify.active", fallback: "알람을 활성화하고  일정관리에 도움을 받아보세요")
    /// 모임 알림
    internal static let meet = L10n.tr("Localizable", "notify.meet", fallback: "모임 알림")
    /// 모임에 관련된 알림
    internal static let meetInfo = L10n.tr("Localizable", "notify.meet_info", fallback: "모임에 관련된 알림")
    /// 일정 알림
    internal static let plan = L10n.tr("Localizable", "notify.plan", fallback: "일정 알림")
    /// 다가오는 일정이나 변동사항에 대한 알림
    internal static let planInfo = L10n.tr("Localizable", "notify.plan_info", fallback: "다가오는 일정이나 변동사항에 대한 알림")
  }
  internal enum Notifylist {
    /// 새로운 알림이 없어요
    internal static let empty = L10n.tr("Localizable", "notifylist.empty", fallback: "새로운 알림이 없어요")
    /// 새로운 알림
    internal static let new = L10n.tr("Localizable", "notifylist.new", fallback: "새로운 알림")
  }
  internal enum Photo {
    /// 기본 이미지로 변경
    internal static let defaultImage = L10n.tr("Localizable", "photo.default_image", fallback: "기본 이미지로 변경")
    /// 사진 접근 권한을 허용해주세요
    internal static let permissionInfo = L10n.tr("Localizable", "photo.permission_info", fallback: "사진 접근 권한을 허용해주세요")
    /// 더 쉽고 편하게 사진을 등록할 수 있어요
    internal static let permissionSubinfo = L10n.tr("Localizable", "photo.permission_subinfo", fallback: "더 쉽고 편하게 사진을 등록할 수 있어요")
    /// 앨범에서 사진 선택
    internal static let selectImage = L10n.tr("Localizable", "photo.select_image", fallback: "앨범에서 사진 선택")
  }
  internal enum Picker {
    /// 날짜선택
    internal static let date = L10n.tr("Localizable", "picker.date", fallback: "날짜선택")
    /// 모임선택
    internal static let meet = L10n.tr("Localizable", "picker.meet", fallback: "모임선택")
    /// 시간선택
    internal static let time = L10n.tr("Localizable", "picker.time", fallback: "시간선택")
  }
  internal enum Placedetail {
    /// 약속장소 길찾기
    internal static let findLoad = L10n.tr("Localizable", "placedetail.find_load", fallback: "약속장소 길찾기")
    /// 카카오 지도
    internal static let mapKakao = L10n.tr("Localizable", "placedetail.map_kakao", fallback: "카카오 지도")
    /// 네이버 지도
    internal static let mapNaver = L10n.tr("Localizable", "placedetail.map_naver", fallback: "네이버 지도")
  }
  internal enum Postdetail {
    /// 일정 삭제
    internal static let deletePlan = L10n.tr("Localizable", "postdetail.delete_plan", fallback: "일정 삭제")
    /// 후기 상세
    internal static let deleteReview = L10n.tr("Localizable", "postdetail.delete_review", fallback: "후기 상세")
    /// 일정 상세
    internal static let plan = L10n.tr("Localizable", "postdetail.plan", fallback: "일정 상세")
    /// 후기 상세
    internal static let review = L10n.tr("Localizable", "postdetail.review", fallback: "후기 상세")
  }
  internal enum Postlist {
    /// 날짜 정보 없음
    internal static let nonDate = L10n.tr("Localizable", "postlist.non_date", fallback: "날짜 정보 없음")
  }
  internal enum Profile {
    /// 알림 관리
    internal static let notify = L10n.tr("Localizable", "profile.notify", fallback: "알림 관리")
    /// 개인정보 처리방침
    internal static let policy = L10n.tr("Localizable", "profile.policy", fallback: "개인정보 처리방침")
    /// 회원탈퇴
    internal static let resign = L10n.tr("Localizable", "profile.resign", fallback: "회원탈퇴")
    /// 정말 탈퇴하시겠어요?
    internal static let resignInfo = L10n.tr("Localizable", "profile.resign_info", fallback: "정말 탈퇴하시겠어요?")
    /// 회원 탈퇴하면 모임과 일정을 복구할 수 없어요
    internal static let resignSubInfo = L10n.tr("Localizable", "profile.resign_subInfo", fallback: "회원 탈퇴하면 모임과 일정을 복구할 수 없어요")
    /// 로그아웃
    internal static let signout = L10n.tr("Localizable", "profile.signout", fallback: "로그아웃")
    /// 로그아웃 하시겠어요?
    internal static let signoutInfo = L10n.tr("Localizable", "profile.signout_info", fallback: "로그아웃 하시겠어요?")
    /// 마이페이지
    internal static let title = L10n.tr("Localizable", "profile.title", fallback: "마이페이지")
    /// 버전정보
    internal static let version = L10n.tr("Localizable", "profile.version", fallback: "버전정보")
  }
  internal enum Report {
    /// 댓글 신고
    internal static let comment = L10n.tr("Localizable", "report.comment", fallback: "댓글 신고")
    /// 신고 접수가 완료되었습니다.
    internal static let completed = L10n.tr("Localizable", "report.completed", fallback: "신고 접수가 완료되었습니다.")
    /// 일정 신고
    internal static let plan = L10n.tr("Localizable", "report.plan", fallback: "일정 신고")
    /// 후기 신고
    internal static let review = L10n.tr("Localizable", "report.review", fallback: "후기 신고")
  }
  internal enum Review {
    /// 후기 작성
    internal static let create = L10n.tr("Localizable", "review.create", fallback: "후기 작성")
    /// 후기 수정
    internal static let edit = L10n.tr("Localizable", "review.edit", fallback: "후기 수정")
    /// 함께한 순간
    internal static let photoHeader = L10n.tr("Localizable", "review.photo_header", fallback: "함께한 순간")
    /// 아직 후기를 남기지 않았어요
    internal static let suggestionInfo = L10n.tr("Localizable", "review.suggestion_info", fallback: "아직 후기를 남기지 않았어요")
    /// 멤버들과 그날의 추억에 대한 기록을 남기고 공유해 보세요.
    internal static let suggestionSubinfo = L10n.tr("Localizable", "review.suggestion_subinfo", fallback: "멤버들과 그날의 추억에 대한 기록을 남기고 공유해 보세요.")
  }
  internal enum Searchplace {
    /// 검색결과가 없어요
    internal static let empty = L10n.tr("Localizable", "searchplace.empty", fallback: "검색결과가 없어요")
    /// 장소를 검색해주세요
    internal static let input = L10n.tr("Localizable", "searchplace.input", fallback: "장소를 검색해주세요")
    /// 장소 이름 없음
    internal static let nonName = L10n.tr("Localizable", "searchplace.non_name", fallback: "장소 이름 없음")
    /// 최근 검색
    internal static let recent = L10n.tr("Localizable", "searchplace.recent", fallback: "최근 검색")
    /// 장소 선택
    internal static let selected = L10n.tr("Localizable", "searchplace.selected", fallback: "장소 선택")
    /// 약속 장소를 검색해주세요
    internal static let title = L10n.tr("Localizable", "searchplace.title", fallback: "약속 장소를 검색해주세요")
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
