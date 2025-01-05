//
//  PastPlanListViewController.swift
//  Mople
//
//  Created by CatSlave on 1/5/25.
//

import UIKit

final class PastPlanListViewController: UIViewController {
    
    private let emptyPlanView: DefaultEmptyView = {
        let view = DefaultEmptyView()
        view.setTitle(text: TextStyle.Calendar.emptyTitle)
        view.setImage(image: .emptyPlan)
        view.clipsToBounds = true
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setLayout()
    }
    
    private func setLayout() {
        self.view.addSubview(emptyPlanView)
        
        emptyPlanView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.width.lessThanOrEqualTo(self.view)
        }
    }
}
