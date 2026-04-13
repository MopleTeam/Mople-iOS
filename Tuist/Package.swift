// swift-tools-version: 5.9
// SPM 의존성 정의 파일
// 기존 .xcodeproj에 있던 SPM 패키지를 여기서 관리한다
// #if TUIST 블록은 Tuist가 패키지를 처리하는 방식을 설정한다
import PackageDescription

#if TUIST
import ProjectDescription

let packageSettings = PackageSettings(
    productTypes: [:]
)
#endif

let package = Package(
    name: "Mople",
    dependencies: [
        // MARK: - Reactive
        .package(url: "https://github.com/ReactiveX/RxSwift.git",
                 .upToNextMajor(from: "6.7.1")),
        .package(url: "https://github.com/ReactorKit/ReactorKit.git",
                 .upToNextMajor(from: "3.2.0")),
        .package(url: "https://github.com/RxSwiftCommunity/RxDataSources.git",
                 .upToNextMajor(from: "5.0.2")),
        .package(url: "https://github.com/CombineCommunity/RxCombine.git",
                 .upToNextMajor(from: "2.0.1")),

        // MARK: - UI
        .package(url: "https://github.com/SnapKit/SnapKit.git",
                 .upToNextMajor(from: "5.7.1")),
        .package(url: "https://github.com/onevcat/Kingfisher.git",
                 .upToNextMajor(from: "7.12.0")),
        .package(url: "https://github.com/WenchaoD/FSCalendar.git",
                 .upToNextMajor(from: "2.8.4")),

        // MARK: - Network & Data
        .package(url: "https://github.com/davbeck/MultipartForm",
                 .upToNextMajor(from: "0.1.0")),
        .package(url: "https://github.com/realm/realm-swift.git",
                 .upToNextMajor(from: "20.0.0")),

        // MARK: - Firebase (Analytics, Crashlytics, Messaging)
        .package(url: "https://github.com/firebase/firebase-ios-sdk",
                 .upToNextMajor(from: "11.5.0")),

        // MARK: - Platform SDK
        .package(url: "https://github.com/kakao/kakao-ios-sdk",
                 .upToNextMajor(from: "2.23.0")),
        .package(url: "https://github.com/navermaps/SPM-NMapsMap",
                 .upToNextMajor(from: "3.21.0")),
    ]
)
