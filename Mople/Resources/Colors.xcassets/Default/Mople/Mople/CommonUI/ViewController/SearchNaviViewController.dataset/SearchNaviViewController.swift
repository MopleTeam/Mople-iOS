//
//  SearchNavigationView.swift
//  Mople
//
//  Created by CatSlave on 12/22/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class SearchNaviViewController: DefaultViewController {

    // MARK: - Variables
    public var searchViewBottom: ConstraintItem {
        return searchBar.snp.bottom
    }
    
    public var searchQuery: String? {
        return searchBar.searchTextField.text
    }
        
    // MARK: - UI Components
    private(set) var searchBar = SearchNaviBar()

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialsetup()
    }

    // MARK: - UI Setup
    private func initialsetup() {
        setupUI()
    }
    
    private func setupUI() {
        self.view.backgroundColor = .defaultWhite
        self.view.addSubview(searchBar)

        searchBar.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(56)
        }
    }
}


