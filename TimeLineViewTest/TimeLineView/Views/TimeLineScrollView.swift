//
//  TimeLineScrollView.swift
//  Cadence
//
//  Created by Dimitry Panychyk on 10/23/17.
//  Copyright © 2017 Cadence. All rights reserved.
//

import UIKit

class TimeLineScrollView: UIScrollView {
    
    @objc var timeLineView: TimeLineView?
    
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
    
    func applyContentSize() {
        if let timeLineView = timeLineView {
            self.contentSize = timeLineView.timeLineContentSize()
        } else {
            assert(false, "Precondition Error. TimeLineView must not be nil")
        }
    }
    
    public func scroll(date: Date, animate: Bool) {
        if let timeLineView = timeLineView {
            let xDateOffset = timeLineView.xOffsetForDate(date)
            let contentWidthCenter = contentSize.width/2
            
            let xDateOffsetDif = contentSize.width - xDateOffset
            
            if xDateOffsetDif > contentWidthCenter {
                // scroll to the right ---->
                let distanceToFront = xDateOffset
                if distanceToFront < bounds.width/2 {
                    scrollTo(x: 0, animated: animate)
                } else {
                    scrollTo(x: xDateOffset - (bounds.width/2), animated: animate)
                }
            } else {
                // scroll to the left  <----
                
                let distanceToEnd = contentSize.width - xDateOffset
                if distanceToEnd < bounds.width {
                    scrollTo(x: contentSize.width - bounds.width, animated: animate)
                } else {
                    scrollTo(x: (xDateOffset - (bounds.width/2)), animated: animate)
                }
                
            }
            
        } else {
            assert(false, "Precondition Error. TimeLineView must not be nil")
        }
    }
    
    public func scroll(timeInterval: CDateInterval, animate: Bool) {
        if let timeLineView = timeLineView {
            
        } else {
            assert(false, "Precondition Error. TimeLineView must not be nil")
        }
    }
    
    private func scrollTo(x: CGFloat, animated: Bool) {
        if animated {
            DispatchQueue.main.async {
                self.setContentOffset(CGPoint(x: x, y: self.contentOffset.y), animated: animated)
            }
        } else {
            setContentOffset(CGPoint(x: x, y: contentOffset.y), animated: animated)
        }
    }
    
}
