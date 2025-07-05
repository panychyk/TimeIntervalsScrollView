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
    var timeLineViewAppearance: AvailabilityTimelineStyle!
    
    private(set) var isIntersect: Bool = false {
        didSet {
            if oldValue != isIntersect {
                setNeedsDisplay()
            }
        }
    }

    private var colorScheme: ColorScheme {
        if isIntersect {
            return ColorScheme(
                borderColor: timeLineViewAppearance.selectionConflictBorderColor,
                fillColor: timeLineViewAppearance.selectionConflictBackgroundColor
            )
        } else {
            return ColorScheme(
                borderColor: timeLineViewAppearance.selectionBorderColor,
                fillColor: timeLineViewAppearance.selectionBackgroundColor
            )
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
        
        context?.setLineWidth(timeLineViewAppearance.selectionBorderWidth)
        
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
    
    func updateConflictState(_ isIntersect: Bool) {
        self.isIntersect = isIntersect
    }
    
}
