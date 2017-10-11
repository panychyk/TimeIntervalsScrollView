//
//  CSelectedTimeIntervalView.swift
//  TimeScrollViewTest
//
//  Created by Dimitry Panychyk on 10/9/17.
//  Copyright © 2017 d'Man. All rights reserved.
//

import UIKit

protocol CSelectedTimeIntervalViewDelegate: NSObjectProtocol {
    
    func selectedTimeIntervalView(_ selectedTimeIntervalView: CSelectedTimeIntervalView, didChangeEndPoint endPoint: CGPoint) -> (Void)
    func selectedTimeIntervalView(_ selectedTimeIntervalView: CSelectedTimeIntervalView, didFinishScrollingWithEndPoint endPoint: CGPoint) -> (Void)

}

class CSelectedTimeIntervalView: UIView, CThumbViewPanDelegate {
    
    var selectionScope: SelectedTimeIntervalScope?
    
    weak var delegate: CSelectedTimeIntervalViewDelegate?
    
    // Parameters:
    let viewHeight: CGFloat  = 50.0
    let borderWidth: CGFloat = 1.5
        
    var dateInterval: CDateInterval!
    
    // Design:
    let borderColor = UIColor(red: 28.0/255.0, green: 66.0/255.0, blue: 52.0/255.0, alpha: 1.0)
    let fillColor   = UIColor(red: 28.0/255.0, green: 66.0/255.0, blue: 52.0/255.0, alpha: 0.8)
    
    // Subviews:
    var thumbView: CThumbView?
    
    var isAllowThumbView = true
    
    // MARK: - Initialization:
    
    convenience init(showThumbView: Bool) {
        self.init()
        self.isAllowThumbView = showThumbView
        configure()
    }
    
    func configure() {
        self.backgroundColor = .clear
        self.clipsToBounds = false
        if isAllowThumbView {
            let thumbView = CThumbView()
            self.thumbView = thumbView
            thumbView.delegate = self
            self.addSubview(thumbView)
        }
        setNeedsLayout()
    }
    
    // MARK: - Lifecycle:
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)

        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(fillColor.cgColor)
        context?.fill(rect)
        context?.setLineWidth(borderWidth)
        
        var xLineOrigin = rect.minX + (borderWidth/2)
        context?.move(to: CGPoint(x: xLineOrigin, y: rect.minY))
        context?.addLine(to: CGPoint(x: xLineOrigin, y: rect.maxY))
        context?.setStrokeColor(borderColor.cgColor)
        context?.strokePath()
        
        xLineOrigin = rect.maxX - (borderWidth/2)
        context?.move(to: CGPoint(x: xLineOrigin, y: rect.minY))
        context?.addLine(to: CGPoint(x: xLineOrigin, y: rect.maxY))
        context?.setStrokeColor(borderColor.cgColor)
        context?.strokePath()
        thumbView?.setNeedsDisplay()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let rect = self.bounds
        if let thumbView = thumbView {
            thumbView.frame = CGRect(x: rect.maxX - CGFloat(thumbView.viewWidth/2),
                                     y: rect.midY - CGFloat(thumbView.viewHeight/2),
                                     width: thumbView.viewWidth,
                                     height: thumbView.viewHeight)
        }
        setNeedsDisplay()
    }
    
    func updateRect(_ rect: CGRect, newTimeInterval: CDateInterval) {
        frame = rect
        dateInterval = newTimeInterval
        setNeedsDisplay()
    }

    // MARK: - CThumbViewPanDelegate:
    
    func thumbView(_ thumbView: CThumbView, didChangePoint point: CGPoint) -> (Void) {
        self.frame = CGRect(x: self.frame.origin.x,
                            y: self.frame.origin.y,
                            width: point.x,
                            height: self.frame.size.height)
        delegate?.selectedTimeIntervalView(self, didChangeEndPoint: CGPoint(x: self.frame.maxX,
                                                                            y: self.frame.origin.y))
        setNeedsDisplay()
    }
    
    func thumbView(_ thumbView: CThumbView, didFinishScrollingWithPoint point: CGPoint) {
        print("didEndChangePoint = \(point)")
        delegate?.selectedTimeIntervalView(self, didFinishScrollingWithEndPoint: point)
        // TODO: move end date to nearest time index
        
    }
    
}



















