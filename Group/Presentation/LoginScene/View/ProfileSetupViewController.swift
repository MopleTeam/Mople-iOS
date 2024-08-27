//
//  ProfileSetupViewController.swift
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

class ProfileSetupViewController: UIViewController, StoryboardView {
    typealias Reactor = ProfileSetupViewReactor
    
    // MARK: - Variables
    private let photoManager: PhotoService
    
    var disposeBag = DisposeBag()
    
    // MARK: - UI Components
    private let testBackButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .systemMint
        btn.setTitle("Back(테스트)", for: .normal)
        return btn
    }()
    
    private let mainTitle: DefaultLabel = {
        let label = DefaultLabel(configure: AppDesign.Profile.main)
        label.numberOfLines = 2
        return label
    }()
    
    private let imageContainerView : UIView = {
        let view = UIView()
        return view
    }()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = AppDesign.Profile.profileImage
        imageView.backgroundColor = .systemRed
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    private let nameTitle = DefaultLabel(configure: AppDesign.Profile.nameTitle)
    
    private let nameTextFieldContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hexCode: "F6F8FA")
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    private let nameTextField = DefaultTextField(configure: AppDesign.Profile.nameText)
    
    private let nameCheckButton = DefaultButton(backColor: AppDesign.Profile.checkButtonBackColor,
                                                radius: 6,
                                                textConfigure: AppDesign.Profile.checkButton)
    
    private let nameCheckContanierView: UIView = {
        let view = UIView()
        view.setContentHuggingPriority(.init(1), for: .vertical)
        return view
    }()
    
    private let nameCheckLabel = DefaultLabel(configure: AppDesign.Profile.checkTitle)
    
    private lazy var nameStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [nameTitle, nameTextFieldContainer, nameCheckContanierView])
        sv.axis = .vertical
        sv.spacing = 8
        sv.alignment = .fill
        sv.distribution = .fill
        return sv
    }()
    
    private var nextButton: DefaultButton = {
        let button = DefaultButton(backColor: AppDesign.Profile.nextButtonBackColor,
                                   radius: 8,
                                   textConfigure: AppDesign.Profile.nextButton)
        button.isEnabled = false
        return button
    }()
    
    private lazy var profileStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [mainTitle, imageContainerView, nameStackView, nextButton])
        sv.axis = .vertical
        sv.spacing = 20
        sv.alignment = .fill
        sv.distribution = .fill
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = .init(top: 28, left: 20, bottom: 28, right: 20)
        return sv
    }()
    
    
    // MARK: - LifeCycle
    init(photoManager: PhotoService,
         reactor: ProfileSetupViewReactor) {
        defer { self.reactor = reactor }
        self.photoManager = photoManager
        super.init(nibName: nil, bundle: nil)
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
        setupTextField()
        setupAction()
    }

    private func setupLayout() {
        self.view.backgroundColor = .white
        self.view.addSubview(profileStackView)
        self.imageContainerView.addSubview(profileImageView)
        self.nameTextFieldContainer.addSubview(nameTextField)
        self.nameCheckContanierView.addSubview(nameCheckLabel)
        
        self.view.addSubview(testBackButton)
        
        testBackButton.snp.makeConstraints { make in
            make.top.trailing.equalTo(self.view.safeAreaLayoutGuide)
        }
        
        profileStackView.snp.makeConstraints { make in
            make.edges.equalTo(self.view.safeAreaLayoutGuide)
        }
        
        profileImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(80)
            make.top.bottom.equalToSuperview().inset(40)
        }

        nameTextFieldContainer.snp.makeConstraints { make in
            make.height.equalTo(56)
        }

        nameTextField.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview().inset(8)
        }
        
        nameCheckLabel.snp.makeConstraints { make in
            make.leading.top.equalToSuperview()
        }
        
        nextButton.snp.makeConstraints { make in
            make.height.equalTo(56)
        }
    }
    
    private func setupTextField() {
        self.nameTextField.rightViewMode = .always
        self.nameTextField.rightView = nameCheckButton
    }
    
    // MARK: - Selectors
    func bind(reactor: ProfileSetupViewReactor) {
        self.nameCheckButton.rx.controlEvent(.touchUpInside)
            .compactMap({ _ in
                return self.nameTextField.text
            })
            .map { Reactor.Action.checkNickname(name: $0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$nameOverlap)
            .skip(1)
            .asDriver(onErrorJustReturn: false)
            .drive(with: self, onNext: { vc, isOverlap in
                vc.nameCheckLabel.isOverlapCheck = isOverlap
                vc.nextButton.isEnabled = !isOverlap
                vc.endEditNameTextField(bool: !isOverlap)
            })
            .disposed(by: disposeBag)
    }
    
    private func setupAction() {

        let tapGesture = UITapGestureRecognizer()
        self.profileImageView.addGestureRecognizer(tapGesture)

        tapGesture.rx.event
            .bind(with: self, onNext: { vc, _ in
                vc.photoManager.requestPhotoLibraryPermission(delegate: self)
            }).disposed(by: disposeBag)
        
        self.testBackButton.rx.controlEvent(.touchUpInside)
            .subscribe(with: self, onNext: { vc, _ in
                vc.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        
        self.nextButton.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { _ in
                print("Next Button Tapped")
            })
            .disposed(by: disposeBag)
            
    }
    
}

// MARK: - Helper
extension ProfileSetupViewController {
    private func endEditNameTextField(bool: Bool) {
        if bool {
            self.nameTextField.resignFirstResponder()
        }
    }
}

// MARK: - Photos
extension ProfileSetupViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let itemprovider = results.first?.itemProvider,
        itemprovider.canLoadObject(ofClass: UIImage.self) else { return }
        
        itemprovider.loadObject(ofClass: UIImage.self) { image , error  in
            if let error {
                #warning("Present Alert")
                print(error)
            }
            
            if let selectedImage = image as? UIImage{
                
                DispatchQueue.main.async {
                    let targetSize = self.profileImageView.frame.size
                    
                    let resizeImage = selectedImage.resize(size: targetSize, cornerRadius: targetSize.width/2)
                    self.profileImageView.image = resizeImage
                }
            }
        }
    }
}
