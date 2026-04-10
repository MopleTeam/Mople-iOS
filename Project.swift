// Project.swift
// Tuist가 이 파일을 읽어서 .xcodeproj를 자동 생성한다
// 타겟 1개 + configuration(Debug/Release)으로 Dev/Prod 서버를 분리
import ProjectDescription

// MARK: - 공통 설정

let marketingVersion = "1.3.0"
let currentProjectVersion = "8"
let developmentTeam = "LNXWGGBBH6"
let deploymentTarget: DeploymentTargets = .iOS("17.6")

// MARK: - Info.plist

let infoPlist: [String: Plist.Value] = [
    "CFBundleLocalizations": .array([.string("ko")]),

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

    // Network & Data
    .external(name: "MultipartForm"),
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

// MARK: - 타겟 정의 (1개 타겟, Debug/Release로 Dev/Prod 분리)

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
    dependencies: dependencies,
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
        ],
        configurations: [
            // Debug = 개발 서버 (기존 MopleDev)
            .debug(name: "Debug", settings: [
                "PRODUCT_BUNDLE_IDENTIFIER": "com.moim.moimtable.dev",
                "CODE_SIGN_STYLE": "Automatic",
                "OTHER_SWIFT_FLAGS": "-DDEV",
                "API_BASE_URL": "https://dev.zerod.store",
                "MAIN_SCHEME": "mopledev",
                "KAKAO_NATIVE_APP_KEY": "0fcc3c29ae8669444767451bb1e89e7e",
                "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon-Dev",
                "INFOPLIST_KEY_CFBundleDisplayName": "모플 Dev",
            ]),
            // Release = 프로덕션 서버 (기존 Mople)
            .release(name: "Release", settings: [
                "PRODUCT_BUNDLE_IDENTIFIER": "com.moim.moimtable",
                "CODE_SIGN_STYLE": "Manual",
                "API_BASE_URL": "https://prod.zerod.store",
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
            "IPHONEOS_DEPLOYMENT_TARGET": "17.6",
        ],
        configurations: [
            .debug(name: "Debug"),
            .release(name: "Release"),
        ]
    ),
    targets: [
        mopleTarget,
    ]
)
