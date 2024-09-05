//
//  participantImage.swift
//  Group
//
//  Created by CatSlave on 9/5/24.
//

import UIKit
import Kingfisher

final class ParticipantImageView: UIImageView {
    
    var index: Int?
    
    init(index: Int?,
         imagePath: String?) {

        super.init(frame: .zero)
        self.index = index
        self.setImage(imagePath)
        self.setLayer()
        self.backgroundColor = .systemMint
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.height / 2
    }
    
    private func setImage(_ path: String?) {
        guard let path = path else { return }
        let imageUrl = URL(string: path)
        self.kf.setImage(with: imageUrl)
    }
    
    private func setLayer() {
        self.clipsToBounds = true
        
        self.layer.borderWidth = 2
        self.layer.borderColor = AppDesign.defaultWihte.cgColor
    }
    
}
