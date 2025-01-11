//
//  MeetSetupViewController.swift
//  Mople
//
//  Created by CatSlave on 1/8/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit

final class MeetSetupViewController: TitleNaviViewController, View {
    
    typealias Reactor = MeetSetupViewReactor
    
    var disposeBag = DisposeBag()
    
    private let thumbnailImage: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.layer.makeLine(width: 1)
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        view.setContentCompressionResistancePriority(.init(999), for: .horizontal)
        return view
    }()
    
    private let meetNameButton: BaseButton = {
        let btn = BaseButton()
        btn.setTitle(font: FontStyle.Title3.semiBold,
                     normalColor: ColorStyle.Gray._01)
        btn.setImage(image: .editPan)
        btn.setLayoutMargins(inset: .zero)
        return btn
    }()
    
    private let spaceView: UIView = {
        let view = UIView()
        view.setContentHuggingPriority(.init(1), for: .horizontal)
        view.setContentCompressionResistancePriority(.init(1), for: .horizontal)
        return view
    }()
    
    private let sinceDayLabel: UILabel = {
        let label = UILabel()
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.backgroundColor = ColorStyle.BG.input
        label.textAlignment = .center
        return label
    }()
    
    private let memberListButton: BaseButton = {
        let btn = BaseButton()
        btn.setTitle(text: "참여자 목록",
                     font: FontStyle.Title3.medium,
                     normalColor: ColorStyle.Gray._01)
        btn.setButtonAlignment(.left)
        btn.setLayoutMargins(inset: .zero)
        btn.setBgColor(normalColor: ColorStyle.Default.white)
        btn.setLayoutMargins(inset: .init(top: 0, leading: 20, bottom: 0, trailing: 20))
        return btn
    }()
    
    private let memberCountLabel: IconLabel = {
        let label = IconLabel(icon: .listArrow,
                              iconSize: .init(width: 24, height: 24))
        label.setTitle(font: FontStyle.Title3.medium,
                       color: ColorStyle.Gray._06)
        label.setSpacing(4)
        label.setIconAligment(.right)
        return label
    }()
    
    private let leaveButton: BaseButton = {
        let btn = BaseButton()
        btn.setButtonAlignment(.left)
        btn.setLayoutMargins(inset: .zero)
        btn.setBgColor(normalColor: ColorStyle.Default.white)
        btn.setLayoutMargins(inset: .init(top: 0, leading: 20, bottom: 0, trailing: 20))
        return btn
    }()
    
    private lazy var headerStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [thumbnailImage, meetNameButton, spaceView])
        sv.axis = .horizontal
        sv.spacing = 12
        sv.alignment = .center
        sv.distribution = .fill
        return sv
    }()
    
    private lazy var subStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [headerStackView, sinceDayLabel])
        sv.axis = .vertical
        sv.spacing = 24
        sv.alignment = .fill
        sv.distribution = .fill
        sv.backgroundColor = ColorStyle.Default.white
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = .init(top: 20, left: 20, bottom: 20, right: 20)
        return sv
    }()
    
    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [subStackView, memberListButton, leaveButton])
        sv.axis = .vertical
        sv.spacing  = 8
        sv.alignment = .fill
        sv.distribution = .fill
        sv.backgroundColor = ColorStyle.BG.secondary
        return sv
    }()
    
    init(title: String?,
         reactor: MeetSetupViewReactor) {
        super.init(title: title)
        self.reactor = reactor
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initalSetup()
    }
    
    private func initalSetup() {
        setLayout()
        setupNavi()
    }
    
    private func setupNavi() {
        self.setBarItem(type: .left)
        self.setBarItem(type: .right, image: .invite)
    }
    
    
    private func setLayout() {
        self.view.addSubview(mainStackView)
        self.memberListButton.addSubview(memberCountLabel)
        
        mainStackView.snp.makeConstraints { make in
            make.top.equalTo(self.titleViewBottom)
            make.horizontalEdges.equalToSuperview()
        }
        
        sinceDayLabel.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
        
        thumbnailImage.snp.makeConstraints { make in
            make.size.equalTo(40)
        }
        
        [memberListButton, leaveButton].forEach {
            $0.snp.makeConstraints { make in
                make.height.equalTo(56)
            }
        }
        
        memberCountLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(20)
        }
    }
    
    func bind(reactor: MeetSetupViewReactor) {
        naviBar.leftItemEvent
            .map { Reactor.Action.popView }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$meet)
            .asDriver(onErrorJustReturn: nil)
            .compactMap({ $0 })
            .drive(with: self, onNext: { vc, meet in
                vc.setMeetInfo(meet)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$isHost)
            .asDriver(onErrorJustReturn: false)
            .drive(with: self, onNext: { vc, isHost in
                vc.setLeaveButtonText(isHost: isHost)
            })
            .disposed(by: disposeBag)
    }
    
    private func setMeetInfo(_ meet: Meet) {
        _ = thumbnailImage.kfSetimage(meet.meetSummary?.imagePath,
                                      defaultImageType: .meet)
        meetNameButton.title = meet.meetSummary?.name
        setMemberCountLabel(meet.memberCount)
        setSinceLabel(meet.sinceDays)
    }
    
    private func setLeaveButtonText(isHost: Bool) {
        leaveButton.setTitle(text: isHost ? "모임 삭제" : "모임 나가기",
                             font: FontStyle.Title3.medium,
                             normalColor: isHost ? ColorStyle.Default.red : ColorStyle.Gray._01)
    }
    
    private func setMemberCountLabel(_ memberCount: Int?) {
        guard let memberCount else { return }
        memberCountLabel.text = "\(memberCount)명"
    }
    
    private func setSinceLabel(_ sinceDayCount: Int?) {
        let sinceCount = String(sinceDayCount ?? 0)
        let text = "우리가 추억을 쌓은지 \(sinceCount) 일째"
        let defaultAttributed = getAttributedString(text: text)
        setHighlightText(attributedString: defaultAttributed, highlightText: sinceCount)
        sinceDayLabel.attributedText = defaultAttributed
    }
    
    private func getAttributedString(text: String) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttributes(.textAttributes(font: FontStyle.Body1.medium,
                                                  color: ColorStyle.Gray._04),
                                       range: .init(location: 0, length: text.count))
        return attributedString
    }
    
    private func setHighlightText(attributedString: NSMutableAttributedString,
                                  highlightText: String) {
        guard let range = attributedString.string.range(of: highlightText) else { return }
        attributedString.addAttributes(.textAttributes(font: FontStyle.Body1.bold,
                                                       color: ColorStyle.App.primary),
                                       range: .init(range, in: attributedString.string))
    }
}

extension [NSAttributedString.Key: Any] {
    static func textAttributes(font: UIFont,
                               color: UIColor) -> Self {
        return [
            .font: font,
            .foregroundColor: color
        ]
    }
}
