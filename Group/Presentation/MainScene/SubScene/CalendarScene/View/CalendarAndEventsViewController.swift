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
    
    private var calendarHeightObservable: AnyObserver<CGFloat>?
    private var calendarScopeObservable: AnyObserver<ScopeType>?
    
    private let calendarContainerView = UIView()
    
    private lazy var calendarView: CalendarViewController = {
        let calendarView = CalendarViewController(heightObservable: calendarHeightObservable!,
                                                  scopeObservable: calendarScopeObservable!)
        
        calendarView.view.layer.cornerRadius = 16
        calendarView.view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        return calendarView
    }()
    
    private let emptyView: UIView = {
        let view = UIView()
        view.backgroundColor = AppDesign.defaultWihte
        return view
    }()
    
    private let testBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("테스트", for: .normal)
        btn.backgroundColor = .green
        return btn
    }()
    
    init(title: String) {
        super.init(title: title)
        calendarHeightObservable = getCalendarHeightObserver()
        calendarScopeObservable = getCalendarScopeObserver()
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addScheduleListCollectionView()
        addRightButton(setImage: UIImage(named: "Calendar")!)
        setAction()
        setGesture()
    }

    private func setupUI() {
        self.view.addSubview(calendarContainerView)
        self.view.addSubview(emptyView)
                
        calendarContainerView.snp.makeConstraints { make in
            make.top.equalTo(titleViewBottom)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(1) // 최소 높이 설정 (Calender 생성 시 높이 update)
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
    
    private func getCalendarHeightObserver() -> AnyObserver<CGFloat> {
        let heightUpdate: PublishSubject<CGFloat> = .init()
        
        heightUpdate
            .subscribe(with: self, onNext: { vc, height in
                vc.updateCalendarView(height)
            })
            .disposed(by: disposeBag)

        return heightUpdate.asObserver()
    }
    
    private func getCalendarScopeObserver() -> AnyObserver<ScopeType> {
        let scopeUpdate: PublishSubject<ScopeType> = .init()
        
        scopeUpdate
            .debounce(.milliseconds(100), scheduler: MainScheduler.instance)
            .subscribe(with: self, onNext: { vc, scope in
                vc.updateBackgroundColor(scope: scope)
            })
            .disposed(by: disposeBag)
        
        return scopeUpdate.asObserver()
    }
    
    private func updateCalendarView(_ height: CGFloat) {
        UIView.animate(withDuration: 0.33) {
            self.calendarContainerView.snp.updateConstraints { make in
                make.height.equalTo(height)
            }
            
            print("캘린더 뷰 업데이트 ")
            self.view.layoutIfNeeded()
        }
    }
    
    #warning("참고")
    // 애니메이션 중에는 유저 액션이 차단되는데 이를 허용할 수 있는 옵션이 존재
    private func updateBackgroundColor(scope: ScopeType) {
        UIView.animate(withDuration: 0.33, delay: 0, options: .allowUserInteraction) {
            switch scope {
            case .week:
                self.calendarContainerView.backgroundColor = AppDesign.mainBackColor
                self.emptyView.backgroundColor = AppDesign.mainBackColor
            case .month:
                self.calendarContainerView.backgroundColor = AppDesign.defaultWihte
                self.emptyView.backgroundColor = AppDesign.defaultWihte
            }
        }
    }

    private func setAction() {
        self.rightButton.rx.controlEvent(.touchUpInside)
            .subscribe(with: self, onNext: { vc, _ in
                vc.calendarView.changeScope()
            })
            .disposed(by: disposeBag)
    }
    
    #warning("제스처 방식 기록 필요")
    private func setGesture() {
        calendarView.scopeGesture.minimumNumberOfTouches = 1 // 최소 손가락 인식
        calendarView.scopeGesture.maximumNumberOfTouches = 2 // 최대 손가락 인식
        calendarView.scopeGesture.delegate = self
        self.view.addGestureRecognizer(calendarView.scopeGesture)
    }
}

extension CalendarAndEventsViewController: UIGestureRecognizerDelegate {
     /*
      테이블뷰가 상단에 붙어있을 때만 동작
     month인 경우 y가 -인 경우 (화면을 위로 올리는 경우)에만 동작
     왜 사용하지?
     예시로 month인 상태에서 아래 테이블뷰를 리로드 동작이 있다고 가정해보자
     그럼 velocity.y 는 양수일 것 이다.
     사용자는 아래로 스크롤했으나 Calendar Scope는 Month -> Week 으로 변경된다.
    
     조건 1 : 테이블뷰가 최상단에 있을 것
     조건 2 : 캘린더의 타입에 따라서 스크롤 방향에 맞춰 변경할 것
      */
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        //        let shouldBegin = self.tableView.contentOffset.y <= -self.tableView.contentInset.top
        //        if shouldBegin {
        let velocity = self.calendarView.scopeGesture.velocity(in: self.view)
        
        switch self.calendarView.calendar.scope {
            
        case .month:
            return velocity.y < 0
        case .week:
            return velocity.y > 0
        }
    }
    //        return shouldBegin
    
}


#if canImport(SwiftUI) && DEBUG
import SwiftUI

@available(iOS 13, *)
struct TestCalendarAndEventsViewController_Preview: PreviewProvider {
    static var previews: some View {
        CalendarAndEventsViewController(title: "일정관리").showPreview()
    }
}
#endif



