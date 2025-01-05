//
//  DetailGroupViewController.swift
//  Mople
//
//  Created by CatSlave on 1/5/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit

final class DetailMeetViewController: TitleNaviViewController, View {
    typealias Reactor = DetailMeetViewReactor
    
    var disposeBag: DisposeBag = DisposeBag()
    
    private let testLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initalizeSetup()
    }
    
    init(title: String?,
         reactor: DetailMeetViewReactor) {
        print(#function, #line, "LifeCycle Test DetailGroupViewController Created" )
        super.init(title: title)
        self.reactor = reactor
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print(#function, #line, "LifeCycle Test DetailGroupViewController Deinit" )
    }
    
    private func initalizeSetup() {
        setLayout()
    }
    
    private func setLayout() {
        self.view.backgroundColor = .systemMint
        self.view.addSubview(testLabel)
        
        testLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    func bind(reactor: DetailMeetViewReactor) {
        reactor.pulse(\.$id)
            .compactMap({ $0 })
            .map({ "\($0)" })
            .bind(to: testLabel.rx.text)
            .disposed(by: disposeBag)
    }
}
