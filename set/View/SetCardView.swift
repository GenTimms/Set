//
//  SetCardView.swift
//  set
//
//  Created by Genevieve Timms on 01/02/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//

import UIKit

@IBDesignable
class SetCardView: UIView {
    
    let color: UIColor
    let shading: Shading
    let shape: Shape
    let number: Int
    
    var isFaceUp = false { didSet { setNeedsDisplay() }}
    var borderWidth: CGFloat = 1 { didSet { setNeedsDisplay()}}
    
    override var description: String {
        return ("\(number) \(shading.rawValue) \(shape.rawValue) \( String(format:"%.1f", color.cgColor.components![0]))")
    }
    
    //MARK: - INITIALIZATION
    init(shape: Shape, color: UIColor, shading: Shading, number: Int) {
        
        assert((1...3).contains(number), "SetCardView.init number = \(number) must be either 1,2 or 3")
        
        self.color = color
        self.shading = shading
        self.shape = shape
        self.number = number
        
        super.init(frame: CGRect())
        
        backgroundColor = Constants.backgroundColor
        contentMode = .redraw
    }
    
    override init(frame: CGRect) {
        color = UIColor.black
        shading = .filled
        shape = .diamond
        number = 1
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        color = UIColor.black
        shading = .filled
        shape = .diamond
        number = 1
        super.init(coder: aDecoder)
    }
    
    //MARK: - DRAWING
    override func draw(_ rect: CGRect) {
        if isFaceUp {
            for origin in shapeOrigins {
                let shapeRect = CGRect(origin: origin, size: shapeSize)
                
                var path = UIBezierPath()
                color.set()
                
                switch shape {
                case .oval: path = UIBezierPath(ovalIn: shapeRect)
                case .diamond: path = UIBezierPath(diamondIn: shapeRect)
                case .rectangle: path = UIBezierPath(rect: shapeRect)
                }
                UIGraphicsGetCurrentContext()?.saveGState()
                
                switch shading {
                case .unfilled: break
                case .filled: path.fill()
                case .striped: path.stripe(withGapOf: 3);
                }
                path.stroke()
                UIGraphicsGetCurrentContext()?.restoreGState()
            }
            let border = UIBezierPath(roundedRect: bounds, cornerRadius: Constants.cornerRadius)
            border.lineWidth = borderWidth
            border.addClip()
            color.set()
            border.stroke()
            
        } else {
            let border = UIBezierPath(roundedRect: bounds, cornerRadius: Constants.cornerRadius)
            border.lineWidth = borderWidth
            border.addClip()
            color.set()
            border.fill()
            border.stroke()
        }
    }
}

//MARK: - GEOMETRY
extension SetCardView {
    
    struct Constants {
        static let backgroundColor: UIColor = UIColor.white
        static let cornerRadius: CGFloat = 5
    }
    
    private struct SizeRatio {
        static let shapeAspect: CGFloat = 3
        static let insetToShortestSide: CGFloat = 0.1
    }
    
    private var inset: CGFloat {
        return bounds.shortestSide * SizeRatio.insetToShortestSide
    }
    
    private var initialShapeWidth: CGFloat {
        return bounds.shortestSide - inset*2
    }
    
    private var initialShapeHeight: CGFloat {
        return initialShapeWidth / SizeRatio.shapeAspect
    }
    
    private var totalLengthAcrossShapeStackAxis: CGFloat {
        return initialShapeHeight*3 + inset*4
    }
    
    private var shapeStackFitsInBounds: Bool {
        return totalLengthAcrossShapeStackAxis <= bounds.longestSide
    }
    
    private var adjustedShapeHeight: CGFloat {
        return (bounds.longestSide - inset*4) / 3
    }
    
    private var adjustedShapeWidth: CGFloat {
        return adjustedShapeHeight * SizeRatio.shapeAspect
    }
    
    private var shapeSize: CGSize {
        if shapeStackFitsInBounds {
            return CGSize(width: initialShapeWidth, height: initialShapeHeight)
        } else {
            return CGSize(width: adjustedShapeWidth, height: adjustedShapeHeight)
        }
    }
    
    private var shortSideInset: CGFloat {
        return (bounds.shortestSide - shapeSize.width) / 2
    }
    
    private var finalStackHeight: CGFloat {
        return CGFloat(number)*shapeSize.height + (CGFloat(number)-1)*inset
    }
    
    private var firstShapeOrigin: CGPoint {
        if bounds.height > bounds.width {
            return CGPoint(x: shortSideInset, y: (bounds.height - finalStackHeight)/2)
        } else {
            return CGPoint(x: (bounds.width - finalStackHeight)/2, y: bounds.height - shortSideInset)
        }
    }
    
    private var secondShapeOrigin: CGPoint {
        if bounds.height > bounds.width {
            return CGPoint(x: shortSideInset, y: firstShapeOrigin.y + shapeSize.height + inset)
        } else {
            return CGPoint(x: firstShapeOrigin.x + shapeSize.height + inset , y: bounds.height - shortSideInset)
        }
    }
    
    private var thirdShapeOrigin: CGPoint {
        if bounds.height > bounds.width {
            return CGPoint(x: shortSideInset, y: secondShapeOrigin.y + shapeSize.height + inset)
        } else {
            return CGPoint(x: secondShapeOrigin.x + shapeSize.height + inset , y: bounds.height - shortSideInset)
        }
    }
    
    private var shapeOrigins: [CGPoint] {
        var origins = [firstShapeOrigin]
        
        if number > 1 {
            origins.append(secondShapeOrigin)
        }
        
        if number > 2 {
            origins.append(thirdShapeOrigin)
        }
        return origins
    }
}
