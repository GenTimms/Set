//
//  DeckView.swift
//  set
//
//  Created by Genevieve Timms on 08/02/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//

import UIKit

@IBDesignable
class DeckView: UIView {
    
    lazy var label = createLabel()
    var backColor = UIColor.black {didSet { setNeedsDisplay() }}
    
    func createLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 1
        addSubview(label)
        label.textAlignment = .center
        label.textColor = UIColor.white
        return label
    }

    var labelFrame: CGRect {
        let size = CGSize(width: bounds.width, height: bounds.width/4)
        let origin = CGPoint(x: 0, y: bounds.width/8)
        return CGRect(origin: origin, size: size)
    }
    
    override func layoutSubviews() {
        label.frame = labelFrame     
    }
    
    override func draw(_ rect: CGRect) {
        let border = UIBezierPath(roundedRect: bounds, cornerRadius: 10)
        border.lineWidth = 2
        border.addClip()
        backColor.setFill()
        UIColor.darkGray.setStroke()
        border.fill()
        border.stroke()
    }
}
