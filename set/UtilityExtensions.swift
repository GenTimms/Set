//
//  UtilityExtensions.swift
//  set
//
//  Created by Genevieve Timms on 18/01/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//

import Foundation
import UIKit

extension Int {
    var arc4random: Int {
        if self > 0 {
            return Int(arc4random_uniform(UInt32(self)))
        } else if self < 0 {
            return -Int(arc4random_uniform(UInt32(abs(self))))
        } else {
            return 0
        }
    }
}

extension CGFloat {
    var arc4random: CGFloat {
        if self > 0 {
            return CGFloat(arc4random_uniform(UInt32(self)))
        } else if self < 0 {
            return -CGFloat(arc4random_uniform(UInt32(abs(self))))
        } else {
            return 0
        }
    }
}

extension Array {
    var shuffled: [Element] {
        var shuffledArray = [Element]()
        for element in self {
            shuffledArray.insert(element, at: shuffledArray.count.arc4random)
        }
        return shuffledArray
    }
}

extension Array where Element: Equatable {
    var allElementsMatch: Bool {
        if let firstElement = self.first {
            if !self.contains { $0 != firstElement } {
                return true
            }
        }
        return false
    }
    
    var allElementsDistinct: Bool {
        var temporarySelf = self
        for element in self {
            temporarySelf.removeFirst()
            if temporarySelf.contains(element) {
                
                return false
            }
        }
        return true
    }
}

extension UIBezierPath {
    convenience init(diamondIn rect: CGRect) {
        self.init()
        move(to: CGPoint(x: rect.minX, y: rect.midY))
        addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        close()
    }
    
    func stripe(withGapOf distance: Int) {
        addClip()
        
        for stripeYPosition in stride(from: bounds.minY, through: bounds.maxY, by: CGFloat(distance)) {
            
            move(to: CGPoint(x: bounds.minX, y: stripeYPosition))
            addLine(to: CGPoint(x: bounds.maxX, y: stripeYPosition))
        }
    }
}

extension CGRect {
    var shortestSide: CGFloat {
        return min(width, height)
    }
    
    var longestSide: CGFloat {
        return max(width, height)
    }
}
