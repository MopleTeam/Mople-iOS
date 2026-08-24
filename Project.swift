// Project.swift
// Tuist가 이 파일을 읽어서 .xcodeproj를 자동 생성한다
// 타겟 1개 + configuration(Debug/Release)으로 Dev/Prod 서버를 분리
import ProjectDescription

// MARK: - 공통 설정

let marketingVersion = "1.5.0"
let currentProjectVersion = "8"
let developmentTeam = "LNXWGGBBH6"
let deploymentTarget: DeploymentTargets = .iOS("18.0")

// MARK: - Info.plist

let infoPlist: [String: Plist.Value] = [
    "CFBundleLocalizations": .array([.string("ko")]),

    // 버전 정보를 base settings(MARKETING_VERSION / CURRENT_PROJECT_VERSION)에 연결
    // Tuist extendingDefault는 이 두 키에 "1.0" / "1"을 리터럴로 심어놓기 때문에
    // 명시적으로 빌드 변수를 가리키도록 덮어써야 실제 앱 버전이 Info.plist에 반영된다.
    "CFBundleShortVersionString": .string("$(MARKETING_VERSION)"),
    "CFBundleVersion": .string("$(CURRENT_PROJECT_VERSION)"),

    // iOS 26 Liquid Glass 디자인 opt-out (기존 UI 유지)
    // 앱이 새 디자인 언어에 대응되기 전까지 호환 모드로 렌더링
    "UIDesignRequiresCompatibility": .boolean(true),

    // URL Schemes (카카오, 딥링크)
    "CFBundleURLTypes": .array([
        .dictionary([
            "CFBundleTypeRole": .string("Editor"),
            "CFBundleURLName": .string("$(PRODUCT_BUNDLE_IDENTIFIER)"),
            "CFBundleURLSchemes": .array([.string("$(PRODUCT_BUNDLE_IDENTIFIER)")])
        ]),
        .dictionary([
            "CFBundleTypeRole": .string("Editor"),
            "CFBundleURLSchemes": .array([.string("kakao$(KAKAO_NATIVE_APP_KEY)")])
        ]),
        .dictionary([
            "CFBundleTypeRole": .string("Editor"),
            "CFBundleURLName": .string("$(PRODUCT_BUNDLE_IDENTIFIER).invite"),
            "CFBundleURLSchemes": .array([.string("mople")])
        ]),
    ]),

    "FirebaseAutomaticScreenReportingEnabled": .boolean(false),
    "ITSAppUsesNonExemptEncryption": .boolean(false),
    "KakaoKey": .string("$(KAKAO_NATIVE_APP_KEY)"),

    "LSApplicationQueriesSchemes": .array([
        .string("kakaokompassauth"),
        .string("kakaomap"),
        .string("nmap"),
    ]),

    "NSAppTransportSecurity": .dictionary([
        "NSAllowsArbitraryLoads": .boolean(true)
    ]),

    "NaverClientId": .string("$(NAVER_CLIENT_ID)"),
    "PolicyURL": .string("$(POLICY_URL)"),

    "UIAppFonts": .array([
        .string("Pretendard-Black.ttf"),
        .string("Pretendard-Bold.ttf"),
        .string("Pretendard-ExtraBold.ttf"),
        .string("Pretendard-ExtraLight.ttf"),
        .string("Pretendard-Light.ttf"),
        .string("Pretendard-Medium.ttf"),
        .string("Pretendard-Regular.ttf"),
        .string("Pretendard-SemiBold.ttf"),
        .string("Pretendard-Thin.ttf"),
    ]),

    "ApiBaseURL": .string("$(API_BASE_URL)"),
    "mainScheme": .string("$(MAIN_SCHEME)"),

    "NSLocationWhenInUseUsageDescription": .string("사용자 위치 기반 서비스를 제공하기 위해 위치 정보 접근 권한이 필요합니다."),
    "NSPhotoLibraryUsageDescription": .string("프로필과 게시글 사진 업로드 기능을 사용하기 위해 사진 라이브러리 접근 권한이 필요합니다."),

    "UIApplicationSupportsIndirectInputEvents": .boolean(true),
    "UILaunchStoryboardName": .string("LaunchScreen"),
    "UISupportedInterfaceOrientations": .array([.string("UIInterfaceOrientationPortrait")]),
]

// MARK: - 소스 및 리소스

let sources: SourceFilesList = ["Mople/**"]

let resources: ResourceFileElements = [
    "Mople/Resources/**",
    "Mople/GoogleService-Info.plist",
    "Mople/GoogleService-Dev-Info.plist",
    "!Mople/Resources/FontStyle.swift",
]

// MARK: - SPM 의존성

let dependencies: [TargetDependency] = [
    // Reactive
    .external(name: "RxSwift"),
    .external(name: "RxCocoa"),
    .external(name: "RxRelay"),
    .external(name: "ReactorKit"),
    .external(name: "RxDataSources"),
    .external(name: "Differentiator"),
    .external(name: "RxCombine"),

    // UI
    .external(name: "SnapKit"),
    .external(name: "Kingfisher"),
    .external(name: "FSCalendar"),

    // Network & Data (MultipartForm은 Data 모듈로 이전, Realm은 AppDelegate migration용 유지)
    .external(name: "Realm"),
    .external(name: "RealmSwift"),

    // Firebase — FirebaseAnalytics는 binary target이라 직접 의존 시 xcframework 충돌 발생
    // FirebaseCrashlytics/Messaging이 transitively 포함하므로 코드에서는 import Firebase 사용
    .external(name: "FirebaseCrashlytics"),
    .external(name: "FirebaseMessaging"),

    // Platform SDK
    .external(name: "KakaoSDKAuth"),
    .external(name: "KakaoSDKCommon"),
    .external(name: "KakaoSDKUser"),
    .external(name: "NMapsMap"),
]

// MARK: - 빌드 스크립트

let swiftgenScript: TargetScript = .pre(
    script: """
    if which swiftgen > /dev/null; then
      swiftgen config run --config "${PROJECT_DIR}/swiftgen.yml"
    else
      echo "warning: SwiftGen이 설치되어 있지 않습니다. brew install swiftgen으로 설치해주세요."
    fi
    """,
    name: "SwiftGen",
    basedOnDependencyAnalysis: false
)

let crashlyticsScript: TargetScript = .post(
    script: """
    "${SRCROOT}/Tuist/.build/checkouts/firebase-ios-sdk/Crashlytics/run"
    """,
    name: "Firebase Crashlytics",
    inputPaths: [
        "${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}",
        "${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Resources/DWARF/${PRODUCT_NAME}",
        "${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Info.plist",
        "$(TARGET_BUILD_DIR)/$(UNLOCALIZED_RESOURCES_FOLDER_PATH)/GoogleService-Info.plist",
        "$(TARGET_BUILD_DIR)/$(EXECUTABLE_PATH)",
    ]
)

// MARK: - Core 모듈 (프로젝트 공통 유틸리티, 순수 Extension, Protocol)
// Domain/Data/Presentation에 의존하지 않는 순수 코드만 포함

let coreTarget: Target = .target(
    name: "Core",
    destinations: .iOS,
    product: .framework,
    bundleId: "com.moim.moimtable.core",
    deploymentTargets: deploymentTarget,
    sources: ["Modules/Core/Sources/**"],
    dependencies: [],
    settings: .settings(
        base: [
            "SWIFT_VERSION": "5.0",
        ],
        configurations: [
            .debug(name: "Debug"),
            .release(name: "Release"),
        ]
    )
)

// MARK: - Domain 모듈 (Entity, UseCase, Repository 인터페이스)
// 외부 의존성 없음 (Foundation만). Clean Architecture의 핵심 레이어

let domainTarget: Target = .target(
    name: "Domain",
    destinations: .iOS,
    product: .framework,
    bundleId: "com.moim.moimtable.domain",
    deploymentTargets: deploymentTarget,
    sources: ["Modules/Domain/Sources/**"],
    dependencies: [],
    settings: .settings(
        base: [
            "SWIFT_VERSION": "5.0",
        ],
        configurations: [
            .debug(name: "Debug", settings: [
                "OTHER_SWIFT_FLAGS": "-DDEV",
            ]),
            .release(name: "Release"),
        ]
    )
)

// MARK: - Data 모듈 (Repository 구현체, DTO, Network, Persistent Storage)
// Domain에 의존, App에서 import. Realm/MultipartForm 등 외부 라이브러리 사용

let dataTarget: Target = .target(
    name: "Data",
    destinations: .iOS,
    product: .framework,
    bundleId: "com.moim.moimtable.data",
    deploymentTargets: deploymentTarget,
    sources: ["Modules/Data/Sources/**"],
    dependencies: [
        .target(name: "Core"),
        .target(name: "Domain"),
        .external(name: "RealmSwift"),
        .external(name: "Realm"),
        .external(name: "MultipartForm"),
    ],
    settings: .settings(
        base: [
            "SWIFT_VERSION": "5.0",
        ],
        configurations: [
            .debug(name: "Debug", settings: [
                "OTHER_SWIFT_FLAGS": "-DDEV -DDEBUG",
            ]),
            .release(name: "Release"),
        ]
    )
)

// MARK: - 앱 타겟 (Debug/Release로 Dev/Prod 분리)

let mopleTarget: Target = .target(
    name: "Mople",
    destinations: .iOS,
    product: .app,
    bundleId: "com.moim.moimtable",
    deploymentTargets: deploymentTarget,
    infoPlist: .extendingDefault(with: infoPlist),
    sources: sources,
    resources: resources,
    entitlements: "Mople/Mople.entitlements",
    scripts: [swiftgenScript, crashlyticsScript],
    dependencies: dependencies + [.target(name: "Core"), .target(name: "Domain"), .target(name: "Data")],
    settings: .settings(
        base: [
            "MARKETING_VERSION": "\(marketingVersion)",
            "CURRENT_PROJECT_VERSION": "\(currentProjectVersion)",
            "DEVELOPMENT_TEAM": "\(developmentTeam)",
            "SWIFT_VERSION": "5.0",
            "OTHER_LDFLAGS": "-ObjC",
            "NAVER_CLIENT_ID": "8bkhfu6fsk",
            "POLICY_URL": "https://unexpected-buckaroo-42a.notion.site/1bc90068602b80788c47c34d1bc3025f?pvs=4",
            "INFOPLIST_KEY_LSApplicationCategoryType": "public.app-category.lifestyle",
            "TARGETED_DEVICE_FAMILY": "1",
            // Xcode 15+ 에셋 카탈로그 → Swift symbol 자동 생성 (UIColor.bgPrimary 등)
            "ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS": "YES",
            // Mac(Designed for iPad) run destination 숨김 — iPhone 전용 앱이라 실수로 Mac 빌드 방지
            "SUPPORTS_MAC_DESIGNED_FOR_IPHONE_IPAD": "NO",
            // NSLocalizedString 호출을 컴파일러가 자동 추출해 .strings 생성 (Tuist 이전 상태 복구)
            "SWIFT_EMIT_LOC_STRINGS": "YES",
        ],
        configurations: [
            // Debug = 개발 서버 (기존 MopleDev)
            .debug(name: "Debug", settings: [
                "PRODUCT_BUNDLE_IDENTIFIER": "com.moim.moimtable.dev",
                "CODE_SIGN_STYLE": "Automatic",
                "OTHER_SWIFT_FLAGS": "-DDEV",
                "API_BASE_URL": "https://dev.2erod.com",
                "MAIN_SCHEME": "mopledev",
                "KAKAO_NATIVE_APP_KEY": "0fcc3c29ae8669444767451bb1e89e7e",
                "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon-Dev",
                "INFOPLIST_KEY_CFBundleDisplayName": "모플 Dev",
            ]),
            // Release = 프로덕션 서버 (기존 Mople)
            .release(name: "Release", settings: [
                "PRODUCT_BUNDLE_IDENTIFIER": "com.moim.moimtable",
                "CODE_SIGN_STYLE": "Manual",
                // Tuist 전환 시 누락된 Manual 서명 지정 (App Store 배포 archive용)
                "CODE_SIGN_IDENTITY": "Apple Distribution",
                "PROVISIONING_PROFILE_SPECIFIER": "Mople Distribution",
                "API_BASE_URL": "https://prod.2erod.com",
                "MAIN_SCHEME": "mople",
                "KAKAO_NATIVE_APP_KEY": "72b95832d0237fce2c5c7eb82d4a6a7a",
                "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon",
                "INFOPLIST_KEY_CFBundleDisplayName": "모플",
            ]),
        ]
    )
)

// MARK: - 프로젝트 정의

let project = Project(
    name: "Mople",
    settings: .settings(
        base: [
            "IPHONEOS_DEPLOYMENT_TARGET": "18.0",
        ],
        configurations: [
            .debug(name: "Debug"),
            .release(name: "Release"),
        ]
    ),
    targets: [
        coreTarget,
        domainTarget,
        dataTarget,
        mopleTarget,
    ]
)
