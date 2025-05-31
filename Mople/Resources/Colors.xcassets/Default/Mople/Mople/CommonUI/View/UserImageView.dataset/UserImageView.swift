//
//  participantImage.swift
//  Group
//
//  Created by CatSlave on 9/5/24.
//

import UIKit
import RxSwift
import Kingfisher

final class UserImageView: UIImageView {
    
    // MARK: - Variables
    private var isSetRadius: Bool = false
    private var task: DownloadTask?
    fileprivate var imagePath: String?
    
    // MARK: - Gesture
    fileprivate let tapGesture: UITapGestureRecognizer = .init()
    
    // MARK: - LifeCycle
    init() {
        super.init(frame: .zero)
        self.isUserInteractionEnabled = true
        defaultImage()
        setGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        task?.cancel()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setRadius()
    }
    
    // MARK: - UI Setup
    private func setRadius() {
        guard !isSetRadius else { return }
        self.layer.cornerRadius = self.frame.height / 2
        self.clipsToBounds = true
        isSetRadius = true
    }
    
    private func defaultImage() {
        self.image = .defaultUser
        self.contentMode = .scaleAspectFill
    }
    
    // MARK: - Setup Gesture
    private func setGesture() {
        self.addGestureRecognizer(tapGesture)
    }
}

extension UserImageView {
    public func setImage(_ path: String?) {
        self.imagePath = path
        task = self.kfSetimage(path, defaultImageType: .user)
    }
    
    public func cancleImageLoad() {
        task?.cancel()
    }
    
    public func setLayer() {
        self.layer.makeLine(width: 1)
    }
}

extension Reactive where Base: UserImageView {
    var tap: Observable<Void> {
        return base.tapGesture.rx.event
            .map { _ in }
    }
}


