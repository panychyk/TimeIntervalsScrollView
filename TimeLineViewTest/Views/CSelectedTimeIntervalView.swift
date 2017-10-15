//
//  CSelectedTimeIntervalView.swift
//  TimeScrollViewTest
//
//  Created by Dimitry Panychyk on 10/9/17.
//  Copyright © 2017 d'Man. All rights reserved.
//

import UIKit


class CSelectedTimeIntervalView: UIView {
    
    // Parameters:
    let viewHeight: CGFloat  = 50.0
    let borderWidth: CGFloat = 1.5
    
    private(set) var isIntersectState: Bool = false
    
    // Design:
    private let borderColor = UIColor(red: 28.0/255.0, green: 66.0/255.0, blue: 52.0/255.0, alpha: 1.0)
    private let fillColor   = UIColor(red: 28.0/255.0, green: 66.0/255.0, blue: 52.0/255.0, alpha: 0.8)
    
    private let intersectedBorderColor = UIColor(red: 208.0/255.0, green: 1.0/255.0, blue: 27.0/255.0, alpha: 1.0)
    private let intersectedFillColor   = UIColor(red: 208.0/255.0, green: 1.0/255.0, blue: 27.0/255.0, alpha: 0.3)

    private var colorScheme: ColorSchemeTuple {
        if isIntersectState {
            return (intersectedBorderColor, intersectedFillColor)
        } else {
            return (borderColor, fillColor)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    private func configure() {
        backgroundColor = .clear
        clipsToBounds   = true
    }
    
    // MARK: - Lifecycle:
    
    override var frame: CGRect {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(colorScheme.fillColor.cgColor)
        context?.fill(rect)
        context?.strokePath()
        
        context?.setLineWidth(borderWidth)
        
        var xLineOrigin = rect.minX
        context?.move(to: CGPoint(x: xLineOrigin, y: rect.minY))
        context?.addLine(to: CGPoint(x: xLineOrigin, y: rect.maxY))
        context?.setStrokeColor(colorScheme.borderColor.cgColor)
        context?.strokePath()
        
        xLineOrigin = rect.maxX
        context?.move(to: CGPoint(x: xLineOrigin, y: rect.minY))
        context?.addLine(to: CGPoint(x: xLineOrigin, y: rect.maxY))
        context?.setStrokeColor(colorScheme.borderColor.cgColor)
        context?.strokePath()
    }
    
    func setIntersectState(_ isIntersect: Bool) {
        if isIntersectState != isIntersect {
            isIntersectState = isIntersect
            setNeedsDisplay()
        }
    }
    
}



















