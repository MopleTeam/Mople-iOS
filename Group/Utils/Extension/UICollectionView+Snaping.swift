//
//  UICollectionView+Snaping.swift
//  Group
//
//  Created by CatSlave on 9/3/24.
//

import Foundation
import UIKit

extension UICollectionView {
    
    func verticalSnapToItem(targetContentOffset: UnsafeMutablePointer<CGPoint>,
                            scrollView: UIScrollView,
                            velocity: CGPoint){

        targetContentOffset.pointee = scrollView.contentOffset

        var indexPath = getFirstItems()
        
        let numberOfItems = self.numberOfItems(inSection: indexPath.section)
        
        guard checkLastItem(currentIndex: indexPath.item, totalCount: numberOfItems) else {
            self.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true )
            return
        }
        
        checkVelocity(velocity, &indexPath)

        self.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true )
    }
    
    private func getFirstItems() -> IndexPath {
        var indexPaths = self.indexPathsForVisibleItems.sorted()
        return indexPaths.first!
    }
    
    private func checkLastItem(currentIndex: Int, totalCount: Int) -> Bool {
        
        return currentIndex < (totalCount - 1)
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
