//
//  CalendarViewController.swift
//  Group
//
//  Created by CatSlave on 8/31/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class CalendarAndEventsViewController: BaseViewController {
    
    var disposeBag = DisposeBag()
    
    private let calendarContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = AppDesign.mainBackColor
        return view
    }()
    
    private let calendarView: CalendarViewController = {
        let calendarView = CalendarViewController()
        calendarView.view.layer.cornerRadius = 16
        calendarView.view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        return calendarView
    }()
    
    private let emptyView: UIView = {
        let view = UIView()
        view.backgroundColor = AppDesign.mainBackColor
        return view
    }()
    
    private let testBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("테스트", for: .normal)
        btn.backgroundColor = .green
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addScheduleListCollectionView()
        addRightButton(setImage: UIImage(named: "Calendar")!)
        setAction()
        setupCalendarObserver()
    }

    private func setupUI() {
        self.view.addSubview(calendarContainerView)
        self.view.addSubview(emptyView)
        
        let height = calendarView.calendarMaxHeight
        
        calendarContainerView.snp.makeConstraints { make in
            make.top.equalTo(titleViewBottom)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(height)
        }
        
        emptyView.snp.makeConstraints { make in
            make.top.equalTo(calendarContainerView.snp.bottom)
            make.horizontalEdges.bottom.equalToSuperview()
        }
    }
    
    private func addScheduleListCollectionView() {
        addChild(calendarView)
        calendarContainerView.addSubview(calendarView.view)
        calendarView.didMove(toParent: self)
        calendarView.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupCalendarObserver() {
        self.calendarView.heightObservable
            .skip(1)
            .subscribe(with: self, onNext: { vc, height in
                vc.updateCalendarView(height)
            })
            .disposed(by: disposeBag)
    }
    
    private func updateCalendarView(_ height: CGFloat) {
        UIView.animate(withDuration: 0.33) {
            self.calendarContainerView.snp.updateConstraints { make in
                make.height.equalTo(height)
            }
            self.view.layoutIfNeeded()
        }
    }

    private func setAction() {
        self.rightButton.rx.controlEvent(.touchUpInside)
            .subscribe(with: self, onNext: { vc, _ in
                vc.calendarView.changeScope()
            })
            .disposed(by: disposeBag)
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

@available(iOS 13, *)
struct CalendarAndEventsViewController_Preview: PreviewProvider {
    static var previews: some View {
        CalendarAndEventsViewController(title: "일정관리").showPreview()
    }
}
#endif



