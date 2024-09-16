//
//  UICollectionView+Snaping.swift
//  Group
//
//  Created by CatSlave on 9/3/24.
//

import Foundation
import UIKit

extension UICollectionView {
    
    private var contentWidth: CGFloat {
        return self.contentSize.width
    }
    
    private var boundsWidth: CGFloat {
        return self.bounds.size.width
    }
}

extension UICollectionView {
    
    func verticalSnapToItem(targetContentOffset: UnsafeMutablePointer<CGPoint>,
                            scrollView: UIScrollView,
                            velocity: CGPoint){
        
        targetContentOffset.pointee = scrollView.contentOffset
        
        var indexPath = getFirstItems()
        
        guard checkTopOrBottom(), checkLastItem(indexPath: indexPath, velocityX: velocity.x) else { return }
 
        checkVelocity(velocity, &indexPath)

        self.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true )
    }
    
    private func getFirstItems() -> IndexPath {
        let indexPaths = self.indexPathsForVisibleItems.sorted()
        return indexPaths.first!
    }
    
    private func checkTopOrBottom(threshold: CGFloat = 50) -> Bool {
        print(#function)
        let contentMinOffsetX = self.contentOffset.x
        let contentMaxOffsetX = contentMinOffsetX + boundsWidth
        
        return contentMinOffsetX > 0 && contentMaxOffsetX < contentWidth
    }
    
    private func checkLastItem(indexPath: IndexPath,
                               velocityX: CGFloat) -> Bool {
        
        print(#function)
        let totalCount = self.numberOfItems(inSection: indexPath.section)
        guard indexPath.item >= (totalCount - 1) else { return true }
        
        if velocityX > 0 {
            scrollToFooter(animated: true)
        } else {
            self.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true )
        }
        
        return false
    }
    
    private func scrollToFooter(animated: Bool) {
        let rightmostOffset = CGPoint(x: max(contentWidth - boundsWidth, 0), y: 0)
        
        self.setContentOffset(rightmostOffset, animated: animated)
    }
    
    private func checkVelocity(_ velocity: CGPoint,_ indexPath: inout IndexPath) {
        if velocity.x > 0 {
            indexPath.item += 1
        } else if velocity.x == 0 {
            let cell = self.cellForItem(at: indexPath)!
            let position = self.contentOffset.x - cell.frame.origin.x
            if position > cell.frame.size.width / 2 {
                indexPath.item += 1
            }
        }
    }
}

