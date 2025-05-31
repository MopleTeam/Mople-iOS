//
//  GroupSelectViewController.swift
//  Mople
//
//  Created by CatSlave on 12/14/24.
//

import UIKit
import RxSwift
import RxCocoa

final class MeetSelectViewController: BaseViewController {
    
    // MARK: - Closure
    private var selected: ((Int) -> Void)?
    
    // MARK: - Variables
    private var disposeBag = DisposeBag()
    private let meetList: [MeetSummary]
    
    // MARK: - UI Components
    private let tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .clear
        table.showsVerticalScrollIndicator = false
        table.separatorStyle = .none
        return table
    }()
    
    private lazy var sheetView: DefaultModalView = {
        let sheetView = DefaultModalView(contentView: tableView)
        sheetView.setTitle(L10n.Picker.meet)
        return sheetView
    }()
    
    // MARK: - LifeCycle
    init(meetList: [MeetSummary],
         completion: ((Int) -> Void)? = nil) {
        self.meetList = meetList
        self.selected = completion
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setPresentationStyle()
        bind()
    }
    
    // MARK: - ModalStyle
    private func setPresentationStyle() {
        modalPresentationStyle = .pageSheet
        sheetPresentationController?.detents = [ .medium() ]
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setLayout()
        setupTableView()
    }
    
    private func setLayout() {
        view.addSubview(sheetView)
        
        sheetView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        self.tableView.register(MeetSelectTableCell.self, forCellReuseIdentifier: MeetSelectTableCell.reuseIdentifier)
    }
    
    // MARK: - Action
    private func bind() {
        sheetView.rx.closeEvent
            .asDriver()
            .drive(with: self, onNext: { vc, _ in
                vc.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
}

extension MeetSelectViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meetList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MeetSelectTableCell.reuseIdentifier,
                                                 for: indexPath) as! MeetSelectTableCell
        cell.configure(with: .init(meetSummary: meetList[indexPath.row]))
        cell.selectionStyle = .none
        return cell
    }
}

extension MeetSelectViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selected?(indexPath.row)
        self.dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

