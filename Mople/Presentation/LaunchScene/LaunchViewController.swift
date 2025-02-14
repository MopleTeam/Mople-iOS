//
//  LaunchViewController.swift
//  Mople
//
//  Created by CatSlave on 2/11/25.
//

import UIKit

final class LaunchViewController: DefaultViewController {
    
    private let viewModel: LaunchViewModel
    
    private let logoImage: UIImageView = {
        let view = UIImageView()
        view.image = .launchScreenIcon
        view.contentMode = .center
        return view
    }()
    
    init(viewModel: LaunchViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        viewModel.checkEntry()
    }
    
    private func setLayout() {
        self.view.backgroundColor = ColorStyle.Default.white
        self.view.addSubview(logoImage)
        
        logoImage.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
