//
//  BaseViewContoller.swift
//  Mople
//
//  Created by CatSlave on 1/11/25.
//

import UIKit

class BaseViewController: UIViewController, LifeCycleLoggable {
    
    // MARK: - Alert
    public let alertManager = AlertManager.shared
    public let sheetManager = SheetManager.shared
    
    // MARK: - Properties
    private let className: String
    
    // MARK: - Initialization
    init() {
        self.className = String(describing: type(of: self))
        super.init(nibName: nil, bundle: nil)
        logLifeCycle()
    }
    
    required init?(coder: NSCoder) {
        self.className = String(describing: type(of: self))
        super.init(coder: coder)
        logLifeCycle()
    }
    
    deinit {
        logLifeCycle()
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        logLifeCycle()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        logLifeCycle()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        logLifeCycle()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        logLifeCycle()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        logLifeCycle()
    }
}
