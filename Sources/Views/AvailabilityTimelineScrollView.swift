//
//  TimeLineScrollView.swift
//  Cadence
//
//  Created by Dimitry Panychyk on 10/23/17.
//  Copyright © 2017 Cadence. All rights reserved.
//

import UIKit

public class AvailabilityTimelineScrollView: UIScrollView {
    
    public var timeLineView: AvailabilityTimelineView?
    
    public enum ScrollPosition : Int {
        case left  = 0
        case center = 1
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        startConfigure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        startConfigure()
    }
    
    private func startConfigure() {
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
    }
    
    public func applyContentSize() {
        if let timeLineView = timeLineView {
            self.contentSize = timeLineView.timeLineContentSize()
        } else {
            assert(false, "Precondition Error. TimeLineView must not be nil")
        }
    }
    
    public func scroll(date: Date?, position: ScrollPosition, animate: Bool) {
        scrollTo(x: xContentOffset(date: date, position: position), animated: animate)
    }
    
    public func scroll(timeInterval: DateInterval, position: ScrollPosition, animate: Bool) {
        scrollTo(x: xContentOffset(timeInterval: timeInterval, position: position), animated: animate)
    }
    
    private func xContentOffset(timeInterval: DateInterval?, position: ScrollPosition) -> CGFloat {
        if let timeLineView = timeLineView {
            if let timeInterval = timeInterval {
                let timeLineContentSize = timeLineView.timeLineSafeAreaRect().size
                var startOffset: CGFloat = 0
                var startCoordinateSystemOffset: CGFloat = 0
                var xDateOffset: CGFloat = 0
                
                switch position {
                case .left:
                    startOffset = 0
                    startCoordinateSystemOffset = bounds.width
                    xDateOffset = timeLineView.xOffsetForDate(timeInterval.start)
                case .center:
                    startOffset = bounds.width/2
                    startCoordinateSystemOffset = bounds.width/2
                    xDateOffset = timeLineView.xOffsetForDate(timeInterval.start) + timeLineView.convertToWidth(timeInterval)/2
                }
                
                let contentWidthCenter = timeLineContentSize.width / 2
                
                let xDateOffsetDiff = timeLineContentSize.width - xDateOffset
                
                if xDateOffsetDiff > contentWidthCenter {
                    // scroll to the right ---->
                    let distanceToFront = xDateOffset
                    if distanceToFront < bounds.width/2 {
                        return 0
                    } else {
                        return xDateOffset - startOffset
                    }
                } else {
                    // scroll to the left  <----
                    let distanceToEnd = timeLineContentSize.width - xDateOffset
                    if distanceToEnd < startCoordinateSystemOffset {
                        return contentSize.width - bounds.width
                    } else {
                        return xDateOffset - startOffset
                    }
                }
            } else {
                return 0.0
            }
        } else {
            assert(false, "Precondition Error. TimeLineView must not be nil")
        }
        return 0.0
    }
    
    private func xContentOffset(date: Date?, position: ScrollPosition) -> CGFloat {
        if let timeLineView = timeLineView {
            if let date = date {
                return xContentOffset(
                    timeInterval: DateInterval(start: date, duration: TimeInterval(timeLineView.applyedTimeInterval.rawValue)),
                    position: position
                )
            } else {
                return 0.0
            }
        } else {
            assert(false, "Precondition Error. TimeLineView must not be nil")
        }
        return 0.0
    }
    
    private func scrollTo(x: CGFloat, animated: Bool) {
        if animated {
            setContentOffset(CGPoint(x: x, y: contentOffset.y), animated: animated)
        } else {
            setContentOffset(CGPoint(x: x, y: contentOffset.y), animated: animated)
        }
    }
    
}
