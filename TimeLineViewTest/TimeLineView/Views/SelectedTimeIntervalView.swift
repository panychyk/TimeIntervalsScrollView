//
//  SelectedTimeIntervalView.swift
//  TimeScrollViewTest
//
//  Created by Dimitry Panychyk on 10/9/17.
//  Copyright © 2017 d'Man. All rights reserved.
//

import UIKit


class SelectedTimeIntervalView: UIView {
    
    // Parameters:
    var timeLineViewAppearance: TimeLineViewAppearance!
    
    private(set) var isIntersectState: Bool = false

    private var colorScheme: ColorSchemeTuple {
        if isIntersectState {
            return (timeLineViewAppearance.selectedTimeViewBorderConflictColor,
                    timeLineViewAppearance.selectedTimeViewBackgroundConflictColor)
        } else {
            return (timeLineViewAppearance.selectedTimeViewBorderColor,
                    timeLineViewAppearance.selectedTimeViewBackgroundColor)
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
        
        context?.setLineWidth(timeLineViewAppearance.selectedTimeViewBorderWidth)
        
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



















