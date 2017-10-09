//
//  CThumbView.swift
//  TimeScrollViewTest
//
//  Created by Dimitry Panychyk on 10/9/17.
//  Copyright © 2017 d'Man. All rights reserved.
//

import UIKit

class CThumbView: UIView {

    // Parameters:
    let viewHeight: CGFloat        = 24.0
    let viewWidth: CGFloat         = 11.0
    let viewCornerRadius: CGFloat  = 100.0
    let borderWidth: CGFloat       = 2
    
    // Design:
    let borderColor = UIColor(red: 28.0/255.0, green: 66.0/255.0, blue: 52.0/255.0, alpha: 1.0)
    let fillColor   = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        frame = rect

        let innerBezierPath = UIBezierPath(roundedRect: rect, cornerRadius: viewCornerRadius)
        fillColor.setFill()
        innerBezierPath.fill()
        
        let outerBezierPath = UIBezierPath(roundedRect: rect, cornerRadius: viewCornerRadius)
        outerBezierPath.lineWidth = borderWidth
        borderColor.setStroke()
        outerBezierPath.stroke()
    }

}
