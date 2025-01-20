//
//  ProfileCreateViewController.swift
//  Group
//
//  Created by CatSlave on 8/12/24.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit
import SnapKit
import PhotosUI

class SignUpViewController: DefaultViewController, View {
    typealias Reactor = SignUpViewReactor
    
    var disposeBag = DisposeBag()
    
    // MARK: - Sub Reactor
    let profileSetupReactor: ProfileSetupViewReactor
    
    // MARK: - Observable
    private let completionObservable: PublishSubject<(nickname: String, image: UIImage?)> = .init()
    private let loadingObservable: PublishSubject<Bool> = .init()
    
    // MARK: - UI Components
    private let mainTitle: UILabel = {
        let label = UILabel()
        label.text = TextStyle.ProfileSetup.title
        label.font = FontStyle.Heading.bold
        label.textColor = ColorStyle.Gray._01
        label.numberOfLines = 2
        return label
    }()
    
    private let profileContainerView = UIView()
    
    private lazy var profileSetupView: ProfileSetupViewController = {
        let viewController = ProfileSetupViewController(reactor: profileSetupReactor,
                                                        lodingObserver: loadingObservable.asObserver(),
                                                        completionObserver: completionObservable.asObserver())
        return viewController
    }()
    
    // MARK: - LifeCycle
    init(profileSetupReactor: ProfileSetupViewReactor,
         signUpReactor: SignUpViewReactor) {
        self.profileSetupReactor = profileSetupReactor
        super.init()
        self.reactor = signUpReactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setupLayout()
        addProfileSetupView()
    }

    private func setupLayout() {
        self.view.backgroundColor = .white
        self.view.addSubview(mainTitle)
        self.view.addSubview(profileContainerView)

        mainTitle.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide).inset(28)
            make.horizontalEdges.equalToSuperview().inset(20)
        }

        profileContainerView.snp.makeConstraints { make in
            make.top.equalTo(mainTitle.snp.bottom).offset(24)
            make.horizontalEdges.equalTo(mainTitle.snp.horizontalEdges)
            make.bottom.equalToSuperview().inset(UIScreen.getAdditionalBottomInset())
        }
    }
    
    private func addProfileSetupView() {
        addChild(profileSetupView)
        profileContainerView.addSubview(profileSetupView.view)
        profileSetupView.didMove(toParent: self)
        profileSetupView.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // MARK: - Binding
    #warning("랜덤 닉네임 받는 로직이 viewwillappear로 되어 있었으나 reactor init에서 처리하게 바꿨음 추후 이상있으면 확인 없으면 warning 제거")
    func bind(reactor: SignUpViewReactor) {
        loadingObservable
            .map({ Reactor.Action.setLoading(isLoad: $0) })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        completionObservable
            .debug()
            .map { Reactor.Action.singUp(name: $0.nickname, image: $0.image) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$isLoading)
            .asDriver(onErrorJustReturn: false)
            .drive(self.rx.isLoading)
            .disposed(by: disposeBag)
    }
}


