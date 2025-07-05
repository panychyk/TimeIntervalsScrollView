//
//  ThumbView.swift
//  TimeScrollViewTest
//
//  Created by Dimitry Panychyk on 10/9/17.
//  Copyright © 2017 d'Man. All rights reserved.
//

import UIKit

@MainActor protocol TimeSliderThumbViewPanDelegate: NSObjectProtocol {
    
    var allowedSelectionScope: TimeSlotSelectionRange? { get }
    var timeIntervalScope: TimeSlotSelectionRange { get }
    
    func thumbView(_ thumbView: TimeSliderThumbView, didChangePoint point: CGPoint) -> (Void)
    func thumbView(_ thumbView: TimeSliderThumbView, didFinishScrollingWithPoint point: CGPoint) -> (Void)
    
}

let MAX_PAN_VELOCITY = 175.0

class TimeSliderThumbView: UIView, UIGestureRecognizerDelegate {
    
    // Parameters:
    let timeLineViewAppearance: AvailabilityTimelineStyle
    
    lazy var hitAreaBounds: CGRect = {
        let rect = CGRect(origin: self.bounds.origin, size: CGSize(width: (timeLineViewAppearance.thumbSize.width * 2), height: timeLineViewAppearance.thumbSize.height))
        return rect.offsetBy(dx: timeLineViewAppearance.thumbSize.width * 0.2, dy: 0)
    }()
    
    private(set) var isIntersectState: Bool = false
    
    private var colorScheme: ColorScheme {
        if isIntersectState {
            return ColorScheme(
                borderColor: timeLineViewAppearance.thumbConflictBorderColor,
                fillColor: timeLineViewAppearance.thumbConflictBackgroundColor
            )
        } else {
            return ColorScheme(
                borderColor: timeLineViewAppearance.thumbBorderColor,
                fillColor: timeLineViewAppearance.thumbBackgroundColor
            )
        }
    }
    
    private lazy var thumbViewPanGesture = UIPanGestureRecognizer(
        target: self,
        action: #selector(onThumbViewSlideAction(_:))
    )
        
    weak var delegate: TimeSliderThumbViewPanDelegate?
    
    private(set) var isPressed = false
    
    private var prevCenterPoint: CGPoint = .zero
    
    init(style: AvailabilityTimelineStyle) {
        self.timeLineViewAppearance = style
        super.init(frame: .zero)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        thumbViewPanGesture.maximumNumberOfTouches = 1
        thumbViewPanGesture.delegate = self
        addGestureRecognizer(thumbViewPanGesture)
        
        clipsToBounds = true
        backgroundColor = colorScheme.fillColor
        layer.cornerRadius = timeLineViewAppearance.thumbSize.width/2
        layer.borderWidth = timeLineViewAppearance.thumbBorderWidth
        layer.borderColor = colorScheme.borderColor.cgColor
    }
    
    // MARK: - Accessories:
    
    public func setCenter(x: CGFloat, y: CGFloat) {
        center = CGPoint(x: x, y: y)
        prevCenterPoint = center
    }
    
    public func setSize(width: CGFloat, height: CGFloat) {
        let newSize = CGSize(width: width, height: height)
        frame = CGRect(origin: frame.origin, size: newSize)
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
                guard let delegate = delegate else {
                    assertionFailure("ThumbView delegate not set")
                    return
                }
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
