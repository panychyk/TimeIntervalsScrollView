//
//  CThumbView.swift
//  TimeScrollViewTest
//
//  Created by Dimitry Panychyk on 10/9/17.
//  Copyright © 2017 d'Man. All rights reserved.
//

import UIKit

protocol CThumbViewPanDelegate: NSObjectProtocol {
    
    func thumbView(_ thumbView: CThumbView, didChangePoint point: CGPoint) -> (Void)
    func thumbView(_ thumbView: CThumbView, didEndChangePoint point: CGPoint) -> (Void)
}

let MAX_PAN_VELOCITY = 175.0

class CThumbView: UIView, UIGestureRecognizerDelegate {

    // Parameters:
    let viewHeight: CGFloat        = 24.0
    let viewWidth: CGFloat         = 12.0
    let viewCornerRadius: CGFloat  = 100.0
    let borderWidth: CGFloat       = 2
    
    lazy var hitAreaBounds: CGRect = {
        let rect = CGRect(origin: self.bounds.origin, size: CGSize(width: (viewWidth * 2) + 20, height: viewHeight))
        return rect.offsetBy(dx: -(rect.width/2), dy: 0)
    }()
    
    // Design:
    let borderColor = UIColor(red: 28.0/255.0, green: 66.0/255.0, blue: 52.0/255.0, alpha: 1.0)
    let fillColor   = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    
    var thumbViewPanGesture: UIPanGestureRecognizer!
    
    weak var delegate: CThumbViewPanDelegate?
    
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
        thumbViewPanGesture = UIPanGestureRecognizer(target: self, action: #selector(onThumbViewSlideAction(_:)))
        thumbViewPanGesture.delegate = self
        self.addGestureRecognizer(thumbViewPanGesture)
        
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)

        let innerBezierPath = UIBezierPath(roundedRect: rect, cornerRadius: viewCornerRadius)
        fillColor.setFill()
        innerBezierPath.fill()
        
        let outerBezierPath = UIBezierPath(roundedRect: rect, cornerRadius: viewCornerRadius)
        outerBezierPath.lineWidth = borderWidth
        borderColor.setStroke()
        outerBezierPath.stroke()
    }
    
    // MARK: - Accessories:
    
    @objc func onThumbViewSlideAction(_ sender: UIPanGestureRecognizer) {
        let point = sender.location(in: self.superview)
        
        switch sender.state {
        case .changed:
            center = CGPoint(x: point.x, y: self.frame.midY)
            delegate?.thumbView(self, didChangePoint: point)
        case .ended, .cancelled:
            delegate?.thumbView(self, didEndChangePoint: point)
        default:
            break
        }
    }
    
    // MARK: - UIGestureRecognizerDelegate:
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == thumbViewPanGesture {
            let velocity = thumbViewPanGesture.velocity(in: gestureRecognizer.view)
            if fabsf(Float(velocity.y)) > fabsf(Float(velocity.x)) {
                return false
            }
            if fabsf(Float(velocity.x)) > Float(MAX_PAN_VELOCITY) {
                return false
            }
            return true
        }
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
}
