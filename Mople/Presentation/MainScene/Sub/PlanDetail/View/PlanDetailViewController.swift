//
//  PlanDetailViewController.swift
//  Mople
//
//  Created by CatSlave on 1/11/25.
//

import UIKit
import RxSwift
import ReactorKit

final class PlanDetailViewController: TitleNaviViewController, View {
    
    typealias Reactor = PlanDetailViewReactor
    
    var disposeBag = DisposeBag()
    
    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = false
        return view
    }()
    
    private let contentView = UIView()
    
    private let planInfoView = PlanInfoView()
    
    private let borderView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorStyle.BG.secondary
        return view
    }()
    
    private let tableView: AutoSizingTableView = {
        let table = AutoSizingTableView(frame: .zero, style: .grouped)
        table.isScrollEnabled = false
        table.backgroundColor = .clear
        table.showsVerticalScrollIndicator = false
        table.separatorStyle = .none
        return table
    }()

    init(reactor: PlanDetailViewReactor, title: String?) {
        super.init(title: title)
        self.reactor = reactor
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initalSetup()
        setAction()
    }
    
    private func initalSetup() {
        setLayout()
        setNavi()
        test()
    }
    
    private func setLayout() {
        self.view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(planInfoView)
        contentView.addSubview(borderView)
        contentView.addSubview(tableView)

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(titleViewBottom)
            make.bottom.horizontalEdges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide.snp.width)
        }
        
        planInfoView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
        }
        
        borderView.snp.makeConstraints { make in
            make.top.equalTo(planInfoView.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(8)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(borderView.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    private func setNavi() {
        self.naviBar.setBarItem(type: .left, image: .backArrow)
    }
    
    func bind(reactor: PlanDetailViewReactor) {
        let viewDidLayout = self.rx.viewDidLayoutSubviews
            .take(1)
        
        Observable.combineLatest(viewDidLayout, reactor.pulse(\.$plan))
            .map({ $0.1 })
            .asDriver(onErrorJustReturn: nil)
            .compactMap({ $0 })
            .drive(with: self, onNext: { vc, plan in
                vc.planInfoView.configure(with: .init(plan))
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$isLoading)
            .asDriver(onErrorJustReturn: false)
            .drive(self.rx.isLoading)
            .disposed(by: disposeBag)
    }
    
    private func setAction() {
        self.naviBar.leftItemEvent
            .asDriver()
            .drive(with: self, onNext: { vc, _ in
                vc.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    private func test() {
        tableView.register(ComentTableCell.self, forCellReuseIdentifier: ComentTableCell.reuseIdentifier)
        
        let array = Array(1...10)
            .map { index in
                Meet.mock(id: index, creatorId: 1)
            }
        
        Observable.just(array)
            .asDriver(onErrorJustReturn: [])
            .drive(self.tableView.rx.items(cellIdentifier: ComentTableCell.reuseIdentifier, cellType: ComentTableCell.self)) { index, item, cell in
                cell.hideLine(isLast: array.count-1 == index)
                cell.selectionStyle = .none
            }
            .disposed(by: disposeBag)
    }
}

final class ComentTableCell: UITableViewCell {
    private let profileView: ParticipantImageView = {
        let view = ParticipantImageView()
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        return view
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = FontStyle.Body1.semiBold
        label.textColor = ColorStyle.Gray._08
        label.text = "이름댓글fasdkfjhasdkjfhskdjalfkljasdhlkjasdfjkasdhfjkashdfjkashdfkjlhaskjdhaskljfhkasjd댓글fasdkfjhasdkjfhskdjalfkljasdhlkjasdfjkasdhfjkashdfjkashdfkjlhaskjdhaskljfhkasjd댓글fasdkfjhasdkjfhskdjalfkljasdhlkjasdfjkasdhfjkashdfjkashdfkjlhaskjdhaskljfhkasjd"
        label.setContentCompressionResistancePriority(.init(1), for: .horizontal)
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = FontStyle.Body2.regular
        label.textColor = ColorStyle.Gray._04
        label.setContentHuggingPriority(.init(1), for: .horizontal)
        label.text = "시간댓글"
        return label
    }()
    
    private let menuButton: UIButton = {
        let button = UIButton()
        button.setImage(.menu, for: .normal)
        return button
    }()
    
    private let commentLabel: UILabel = {
        let label = UILabel()
        label.font = FontStyle.Body1.medium
        label.textColor = ColorStyle.Gray._03
        label.numberOfLines = 0
        label.text = "댓글fasdkfjhasdkjfhskdjalfkljasdhlkjasdfjkasdhfjkashdfjkashdfkjlhaskjdhaskljfhkasjd댓글fasdkfjhasdkjfhskdjalfkljasdhlkjasdfjkasdhfjkashdfjkashdfkjlhaskjdhaskljfhkasjd댓글fasdkfjhasdkjfhskdjalfkljasdhlkjasdfjkasdhfjkashdfjkashdfkjlhaskjdhaskljfhkasjd댓글fasdkfjhasdkjfhskdjalfkljasdhlkjasdfjkasdhfjkashdfjkashdfkjlhaskjdhaskljfhkasjd댓글fasdkfjhasdkjfhskdjalfkljasdhlkjasdfjkasdhfjkashdfjkashdfkjlhaskjdhaskljfhkasjd댓글fasdkfjhasdkjfhskdjalfkljasdhlkjasdfjkasdhfjkashdfjkashdfkjlhaskjdhaskljfhkasjd댓글fasdkfjhasdkjfhskdjalfkljasdhlkjasdfjkasdhfjkashdfjkashdfkjlhaskjdhaskljfhkasjd댓글fasdkfjhasdkjfhskdjalfkljasdhlkjasdfjkasdhfjkashdfjkashdfkjlhaskjdhaskljfhkasjd댓글fasdkfjhasdkjfhskdjalfkljasdhlkjasdfjkasdhfjkashdfjkashdfkjlhaskjdhaskljfhkasjd댓글fasdkfjhasdkjfhskdjalfkljasdhlkjasdfjkasdhfjkashdfjkashdfkjlhaskjdhaskljfhkasjd"
        return label
    }()
    
    private lazy var commentHeaderView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [nameLabel, timeLabel, menuButton])
        sv.axis = .horizontal
        sv.spacing = 8
        sv.alignment = .center
        sv.distribution = .fill
        return sv
    }()
    
    private lazy var commentView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [commentHeaderView, commentLabel])
        sv.axis = .vertical
        sv.spacing = 8
        sv.alignment = .fill
        sv.distribution = .fill
        return sv
    }()
    
    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [profileView, commentView])
        sv.axis = .horizontal
        sv.spacing = 12
        sv.alignment = .top
        sv.distribution = .fill
        return sv
    }()
    
    private let borderView: UIView = {
        let view = UIView()
        view.layer.makeLine(width: 1)
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        borderView.isHidden = false
    }
    
    private func setLayout() {
        self.contentView.addSubview(mainStackView)
        self.contentView.addSubview(borderView)
        
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
        }
        
        profileView.snp.makeConstraints { make in
            make.size.equalTo(32)
        }
        
        commentHeaderView.snp.makeConstraints { make in
            make.height.equalTo(24)
        }
        
        commentLabel.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(20)
        }
        
        borderView.snp.makeConstraints { make in
            make.bottom.horizontalEdges.equalToSuperview()
            make.height.equalTo(1)
        }
    }
}

extension ComentTableCell {
    public func hideLine(isLast: Bool) {
        borderView.isHidden = isLast
    }
}
