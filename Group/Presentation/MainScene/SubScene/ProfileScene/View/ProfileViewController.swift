//
//  ProfileViewController.swift
//  Group
//
//  Created by CatSlave on 8/31/24.
//

import UIKit

final class ProfileViewController: BaseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.view.backgroundColor = .systemGray
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print(#function, #line)
    }
}
