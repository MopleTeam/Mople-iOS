//
//  ProfileSetupViewController.swift
//  Group
//
//  Created by CatSlave on 8/12/24.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import SnapKit

class ProfileSetupViewController: UIViewController {
    
    private var disposeBag = DisposeBag()
    
    private var isOverlap: Bool = false
    
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
    
    private let imageContainerView = UIView()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = AppDesign.Profile.profileImage
        imageView.contentMode = .scaleAspectFill
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
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
    
    private func setupAction() {
        
        self.nameCheckButton.rx.controlEvent(.touchUpInside)
            .subscribe(with: self, onNext: { vc, _ in
                vc.nameCheckLabel.isOverlapCheck = vc.isOverlap
                vc.nextButton.isEnabled = !vc.isOverlap
                vc.isOverlap.toggle()
            })
            .disposed(by: disposeBag)
        
        self.testBackButton.rx.controlEvent(.touchUpInside)
            .subscribe(with: self, onNext: { vc, _ in
                vc.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
}
