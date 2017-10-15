//
//  ThumbView.swift
//  TimeScrollViewTest
//
//  Created by Dimitry Panychyk on 10/9/17.
//  Copyright © 2017 d'Man. All rights reserved.
//

import UIKit

protocol ThumbViewPanDelegate: NSObjectProtocol {
    
    var allowedSelectionScope: SelectedTimeIntervalScope? { get }
    var timeIntervalScope: SelectedTimeIntervalScope { get }
    
    func thumbView(_ thumbView: ThumbView, didChangePoint point: CGPoint) -> (Void)
    func thumbView(_ thumbView: ThumbView, didFinishScrollingWithPoint point: CGPoint) -> (Void)
    
}

let MAX_PAN_VELOCITY = 175.0

class ThumbView: UIView, UIGestureRecognizerDelegate {
    
    // Parameters:
    let viewSize = CGSize(width: 12.0, height: 24.0)
    
    private let viewCornerRadius: CGFloat  = 120.0
    private let borderWidth: CGFloat       = 2
    
    lazy var hitAreaBounds: CGRect = {
        let rect = CGRect(origin: self.bounds.origin, size: CGSize(width: (viewSize.width * 2), height: viewSize.height))
        return rect.offsetBy(dx: viewSize.width * 0.2, dy: 0)
    }()
    
    private(set) var isIntersectState: Bool = false
    
    // Design:
    private let borderColor = UIColor(red: 28.0/255.0, green: 66.0/255.0, blue: 52.0/255.0, alpha: 1.0)
    private let fillColor   = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    
    private let intersectedBorderColor = UIColor(red: 208.0/255.0, green: 1.0/255.0, blue: 27.0/255.0, alpha: 1.0)
    private let intersectedFillColor   = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)

    
    private var colorScheme: ColorSchemeTuple {
        if isIntersectState {
            return (intersectedBorderColor, intersectedFillColor)
        } else {
            return (borderColor, fillColor)
        }
    }
    
    private var thumbViewPanGesture: UIPanGestureRecognizer!
        
    weak var delegate: ThumbViewPanDelegate?
    
    private(set) var isPressed = false
    
    private var prevCenterPoint: CGPoint = .zero
    
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
        colorScheme.fillColor.setFill()
        innerBezierPath.fill()
        
        let outerBezierPath = UIBezierPath(roundedRect: rect, cornerRadius: viewCornerRadius)
        outerBezierPath.lineWidth = borderWidth
        colorScheme.borderColor.setStroke()
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
    
    public func setCenter(x: CGFloat, y: CGFloat) {
        center = CGPoint(x: x, y: y)
        prevCenterPoint = center
    }
    
    func setIntersectState(_ isIntersect: Bool) {
        if isIntersectState != isIntersect {
            isIntersectState = isIntersect
            setNeedsDisplay()
        }
    }
    
    @objc private func onThumbViewSlideAction(_ sender: UIPanGestureRecognizer) {
        let pointOnSuperview = sender.location(in: self.superview)
        
        switch sender.state {
        case .began:
            isPressed = true
        case .changed:
            if let delegate = delegate {
                
                var point = pointOnSuperview
                
                let scope = delegate.allowedSelectionScope?.intersect(delegate.timeIntervalScope) ?? delegate.timeIntervalScope
                if (scope.minValueX ... scope.maxValueX ~= prevCenterPoint.x) == false {
                    // calc only by timeIntervalScope
                    let timeIntervalScope = delegate.timeIntervalScope
                    if timeIntervalScope.maxValueX < pointOnSuperview.x {
                        point = CGPoint(x: timeIntervalScope.maxValueX, y: pointOnSuperview.y)
                    } else if timeIntervalScope.minValueX > pointOnSuperview.x {
                        point = CGPoint(x: timeIntervalScope.minValueX, y: pointOnSuperview.y)
                    }
                    setCenter(x: point.x, y: frame.midY)
                    delegate.thumbView(self, didChangePoint: point)
                } else {
                    if scope.maxValueX < pointOnSuperview.x {
                        point = CGPoint(x: scope.maxValueX, y: pointOnSuperview.y)
                    } else if scope.minValueX > pointOnSuperview.x {
                        point = CGPoint(x: scope.minValueX, y: pointOnSuperview.y)
                    }
                    setCenter(x: point.x, y: frame.midY)
                    delegate.thumbView(self, didChangePoint: point)
                }
            } else {
                assert(false, "NotImplementedError")
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
        if thumbViewPanGesture === gestureRecognizer {
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
