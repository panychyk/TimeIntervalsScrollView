//
//  CThumbView.swift
//  TimeScrollViewTest
//
//  Created by Dimitry Panychyk on 10/9/17.
//  Copyright © 2017 d'Man. All rights reserved.
//

import UIKit

protocol CThumbViewPanDelegate: NSObjectProtocol {
    
    var selectionScope: SelectedTimeIntervalScope? { get }
    var timeIntervalScope: SelectedTimeIntervalScope { get }
    
    func thumbView(_ thumbView: CThumbView, didChangePoint point: CGPoint) -> (Void)
    func thumbView(_ thumbView: CThumbView, didFinishScrollingWithPoint point: CGPoint) -> (Void)
    
}

let MAX_PAN_VELOCITY = 175.0

class CThumbView: UIView, UIGestureRecognizerDelegate {

    // Parameters:
    let viewSize = CGSize(width: 12.0, height: 24.0)
    
    private let viewCornerRadius: CGFloat  = 100.0
    private let borderWidth: CGFloat       = 2
    
    lazy var hitAreaBounds: CGRect = {
        let rect = CGRect(origin: self.bounds.origin, size: CGSize(width: (viewSize.width * 2), height: viewSize.height))
        return rect.offsetBy(dx: -10, dy: 0)
    }()
    
    // Design:
    private let borderColor = UIColor(red: 28.0/255.0, green: 66.0/255.0, blue: 52.0/255.0, alpha: 1.0)
    private let fillColor   = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    
    private var thumbViewPanGesture: UIPanGestureRecognizer!
        
    weak var delegate: CThumbViewPanDelegate?
    
    private(set) var isPressed = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    private func configure() {
        self.backgroundColor = .clear
        thumbViewPanGesture = UIPanGestureRecognizer(target: self, action: #selector(onThumbViewSlideAction(_:)))
        thumbViewPanGesture.maximumNumberOfTouches = 1
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
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set {
            super.frame = CGRect(origin: newValue.origin,
                                 size: viewSize)
        }
    }
    
    // MARK: - Accessories:
    
    @objc private func onThumbViewSlideAction(_ sender: UIPanGestureRecognizer) {
        let point = sender.location(in: self.superview)
        
        switch sender.state {
        case .began:
            isPressed = true
        case .changed:
            if let delegate = delegate {
                let scope = delegate.selectionScope?.intersect(delegate.timeIntervalScope) ?? delegate.timeIntervalScope
                if scope.minValueX ... scope.maxValueX ~= point.x {
                    center = CGPoint(x: point.x, y: self.frame.midY)
                    delegate.thumbView(self, didChangePoint: point)
                } else {
//                    sender.isEnabled = false
//                    sender.isEnabled = true
                }
            } else {
                assert(false, "CThumbView.onThumbViewSlideAction(_:) need to set delegate")
            }
        case .ended, .cancelled:
            isPressed = false
            delegate?.thumbView(self, didFinishScrollingWithPoint: self.center)
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
