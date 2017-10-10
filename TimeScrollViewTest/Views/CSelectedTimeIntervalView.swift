//
//  CSelectedTimeIntervalView.swift
//  TimeScrollViewTest
//
//  Created by Dimitry Panychyk on 10/9/17.
//  Copyright © 2017 d'Man. All rights reserved.
//

import UIKit

class CSelectedTimeIntervalView: UIView, CThumbViewPanDelegate {
    
    // Parameters:
    let viewHeight: CGFloat  = 51.0
    let borderWidth: CGFloat = 1.5
        
//    var dateInterval: CDateInterval!
    
    // Design:
    let borderColor = UIColor(red: 28.0/255.0, green: 66.0/255.0, blue: 52.0/255.0, alpha: 1.0)
    let fillColor   = UIColor(red: 28.0/255.0, green: 66.0/255.0, blue: 52.0/255.0, alpha: 0.8)
    
    // Subviews:
    let thumbView = CThumbView()
    
    // MARK: - Initialization:
    
//    convenience init(_ dateInterval: CDateInterval) {
//        self.init()
//        self.dateInterval = dateInterval
//    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    func configure() {
        self.backgroundColor = .clear
        thumbView.delegate = self
        self.addSubview(thumbView)
    }
    
    // MARK: - Lifecycle:
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)

        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(fillColor.cgColor)
        context?.fill(rect)
        context?.setLineWidth(borderWidth)
        context?.move(to: CGPoint(x: rect.minX, y: rect.minY))
        context?.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        context?.setStrokeColor(borderColor.cgColor)
        context?.strokePath()
        context?.move(to: CGPoint(x: rect.maxX, y: rect.minY))
        context?.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        context?.setStrokeColor(borderColor.cgColor)
        context?.strokePath()
        thumbView.setNeedsDisplay()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let rect = self.bounds
        thumbView.frame = CGRect(x: rect.maxX - CGFloat(thumbView.viewWidth/2),
                                 y: rect.midY - CGFloat(thumbView.viewHeight/2),
                                 width: thumbView.viewWidth,
                                 height: thumbView.viewHeight)
        self.setNeedsDisplay()
    }

    // MARK: - CThumbViewPanDelegate:
    
    func thumbView(_ thumbView: CThumbView, didChangePoint point: CGPoint) -> (Void) {
        self.frame = CGRect(x: self.frame.origin.x,
                            y: self.frame.origin.y,
                            width: point.x,
                            height: self.frame.size.height)
        setNeedsDisplay()
    }

    // MARK: - Touch:
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if let view = view, view.isEqual(self) {
            return nil
        }
        return view
    }
    
}
