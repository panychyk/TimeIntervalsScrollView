//
//  CTimeScrollViewCanvas.swift
//  TimeScrollViewTest
//
//  Created by Dimitry Panychyk on 10/1/17.
//  Copyright © 2017 d'Man. All rights reserved.
//

import UIKit

class CTimeScrollViewCanvas: UIView {
    
    private(set) weak var parentView: CTimeScrollView!
    
    lazy var date: Date = {
        return Date().dateWithZeroHourAndMinute(self.parentView.calendar)!
    }()
    
    let blockImage = UIImage(named: "reserved_image")
    
    convenience init(_ parent: CTimeScrollView) {
        let frame = CGRect(origin: parent.bounds.origin, size: parent.contentSize)
        self.init(frame: frame)
        backgroundColor = .white
        parentView = parent
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.setLineWidth(parentView.separatorWidth)
        let startPoint = Int(round((parentView.separatorWidth)/2))
        for xOrigin in stride(from: startPoint, through: Int(rect.width), by: Int(parentView.intervalStepInPx)) {
            let index = xOrigin/Int(parentView.intervalStepInPx)
            appendDate(forIndex: index)
            if xOrigin == Int(rect.width) && (parentView.separatorWidth.truncatingRemainder(dividingBy: 2.0)) != 0 {
                let newX = CGFloat(xOrigin - Int(round((parentView.separatorWidth)/2)))
                drawLine(context,
                         index:   index,
                         xOrigin: newX,
                         rect:    rect)
            } else {
                drawLine(context,
                         index:   index,
                         xOrigin: CGFloat(xOrigin),
                         rect:    rect)
            }
        }
    }
    
    func drawLine(_ context: CGContext?, index: Int, xOrigin: CGFloat, rect: CGRect) {
        var height: CGFloat = parentView.mins60SeparatorHeight
        if index > 0 {
            switch parentView.timeIntervals {
            case .mins15:
                if CGFloat(index).truncatingRemainder(dividingBy: 2.0) != 0 {
                    height = parentView.mins15SeparatorHeight
                } else if CGFloat(index/2).truncatingRemainder(dividingBy: 2.0) != 0 {
                    height = parentView.mins30SeparatorHeight
                }
            case .mins30:
                if CGFloat(index).truncatingRemainder(dividingBy: 2.0) != 0 {
                    height = parentView.mins30SeparatorHeight
                }
            case .mins60:
                break
            }
        }
        let yOrigin = rect.height - height
        
        for dateInterval in parentView.unavailableTimeIntervals {
            if let dateTime = parentView.hashMap[NSNumber(value: index)] {
                if dateInterval.startDate > dateTime.startDate {
                    break
                }
                if dateInterval.contains(dateTime.startDate) && dateInterval.endDate > dateTime.startDate {
                    let imageHeight: CGFloat = 50
                    let r = CGRect(origin: CGPoint(x: CGFloat(xOrigin), y: rect.height - imageHeight), size: CGSize(width: parentView.intervalStepInPx, height: imageHeight))
                    setUnavailable(in: r, at: index)
                    break
                }
            }
        }
        
        if height == parentView.mins60SeparatorHeight {
            if let dateTime = parentView.hashMap[NSNumber(value: index)] {
                drawText(dateTime.startDate.shortHoursString(parentView.calendar),
                         at: CGPoint(x: (xOrigin + 6.0), y: yOrigin))
            }
        }

        context?.setStrokeColor(parentView.separatorColor)
        context?.move(to: CGPoint(x: xOrigin, y: yOrigin))
        context?.addLine(to: CGPoint(x: xOrigin, y: rect.height))
        context?.strokePath()

    }
    
    func setUnavailable(in rect: CGRect, at index: Int) {
        blockImage?.draw(in: rect)
        UIColor(red: 241/255, green: 241/255, blue: 241/255, alpha: 0.6).setFill()
        UIRectFillUsingBlendMode(rect, .multiply)
    }
    
    func drawText(_ text: String, at point: CGPoint) {
        let attributedTimeString = text.attributedString(font:      parentView.timeLabelFont,
                                                         charSpace: parentView.timeLabelCharSpacing,
                                                         tintColor: parentView.timeLabelColor)
        attributedTimeString.draw(at: point)
    }
    
    func appendDate(forIndex index: Int) {
        let startDateTime = date.dateByAppendingSecs(parentView.timeIntervals.rawValue * index, calendar: parentView.calendar)
        let newDateInterval = CDateInterval(start: startDateTime, duration: TimeInterval(parentView.timeIntervals.rawValue))
        parentView.appliedDateInterval(newDateInterval, forIndex: NSNumber(value: index))
    }
    
}
