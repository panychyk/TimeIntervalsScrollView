//
//  CTimeScrollViewCanvas.swift
//  TimeScrollViewTest
//
//  Created by Dimitry Panychyk on 10/1/17.
//  Copyright © 2017 d'Man. All rights reserved.
//

import UIKit

class CTimeIntervalDrawableView: UIView {
    
    private(set) weak var parentView: CTimeIntervalScrollView!
    
    lazy var date: Date = {
        return Date().dateWithZeroHourAndMinute(self.parentView.calendar)!
    }()
    
    
    // MARK: - Lifecycle:
    convenience init(_ parent: CTimeIntervalScrollView) {
        let frame = CGRect(origin: parent.bounds.origin, size: parent.contentSize)
        self.init(frame: frame)
        backgroundColor = .white
        parentView = parent
    }
    
    // MARK: - Draw:
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        drawSeparatorsAndTimeTitles(in: rect)
        drawUnavailableSectors(in: rect)
        drawReservations(in: rect)
    }
    
    // MARK: - Separators:
    func drawSeparatorsAndTimeTitles(in rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.setLineWidth(parentView.separatorWidth)
        let startPoint = Int(round((parentView.separatorWidth)/2))
        for xOrigin in stride(from: startPoint, through: Int(rect.width), by: Int(parentView.intervalStepInPx)) {
            let index = xOrigin/Int(parentView.intervalStepInPx)
            
            appendDate(forIndex: index)
            if xOrigin == Int(rect.width) &&
                (parentView.separatorWidth.truncatingRemainder(dividingBy: 2.0)) != 0 {
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
            switch parentView.applyedTimeInterval {
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
        if height == parentView.mins60SeparatorHeight {
            if let dateTime = parentView.timeSectorsMap[NSNumber(value: index)] {
                drawTimeText(dateTime.startDate.shortHoursString(parentView.calendar),
                         at: CGPoint(x: (xOrigin + 6.0), y: yOrigin))
            }
        }

        context?.setStrokeColor(parentView.separatorColor)
        context?.move(to: CGPoint(x: xOrigin, y: yOrigin))
        context?.addLine(to: CGPoint(x: xOrigin, y: rect.height))
        context?.strokePath()

    }
    
    func drawTimeText(_ text: String, at point: CGPoint) {
        let attributedTimeString = text.attributedString(font:      parentView.timeLabelFont,
                                                         charSpace: parentView.timeLabelCharSpacing,
                                                         tintColor: parentView.timeLabelColor)
        attributedTimeString.draw(at: point)
    }
    
    // MARK: - Unavailable:
    func drawUnavailableSectors(in rect: CGRect) {
        if let timeIntervalScrollViewModel = parentView.timeIntervalScrollViewModel {
            for dateInterval in timeIntervalScrollViewModel.unavailableTimeIntervalsList {
                let fromSectorIndex = dateInterval.startDate.sinceToday(parentView.calendar)/parentView.applyedTimeInterval.rawValue
                let toSectorIndex   = dateInterval.endDate.sinceToday(parentView.calendar)/parentView.applyedTimeInterval.rawValue
                for sectorIndex in stride(from: fromSectorIndex, to: toSectorIndex, by: 1) {
                    let xOrigin = CGFloat(sectorIndex) * parentView.intervalStepInPx
                    let r = CGRect(origin: CGPoint(x: CGFloat(xOrigin),
                                                   y: rect.height - parentView.unavailableSectorImageHeight),
                                   size: CGSize(width: parentView.intervalStepInPx,
                                                height: parentView.unavailableSectorImageHeight))
                    setUnavailable(in: r, at: sectorIndex)
                }
            }
        }
    }
    
    func setUnavailable(in rect: CGRect, at index: Int) {
        parentView.unavailableSectorImage?.draw(in: rect)
        UIColor(red: 241/255, green: 241/255, blue: 241/255, alpha: 0.6).setFill()
        UIRectFillUsingBlendMode(rect, .multiply)
    }
    
    // MARK: - Reserved:
    func drawReservations(in rect: CGRect) {
        if let reservations = parentView.timeIntervalScrollViewModel?.reservadTimeIntervalsList {
            let startPoint = Int(round((parentView.separatorWidth)/2))
            var xOrigin = startPoint
            
            let reservationsMutable = NSMutableArray(array: reservations)
            
            while xOrigin <= Int(rect.width) {
                let index = xOrigin/Int(parentView.intervalStepInPx)
                for reservation in reservationsMutable {
                    if let reservation = (reservation as? ReservationModel),
                        let dateTime = parentView.timeSectorsMap[NSNumber(value: index)] {
                        if reservation.reservationTimeInterval.startDate == dateTime.startDate
//                            && reservation.reservationTimeInterval.duration >= TimeInterval(parentView.applyedTimeInterval.rawValue)
                        {
                            let reservationView = CReservationView(reservation)
                            let numOfMarkedSectors = Int(reservation.reservationTimeInterval.duration) / parentView.applyedTimeInterval.rawValue
                            reservationView.draw(CGRect(x: CGFloat(xOrigin) + parentView.separatorWidth,
                                                        y: rect.height - reservationView.contentHeight,
                                                        width: CGFloat(parentView.intervalStepInPx * CGFloat(numOfMarkedSectors)) - CGFloat(parentView.separatorWidth * 2),
                                                        height: reservationView.contentHeight))
                            
                            reservationsMutable.remove(reservation)
                            xOrigin += Int(parentView.intervalStepInPx) * numOfMarkedSectors
                            break
                        }
                    }
                }
                xOrigin += Int(parentView.intervalStepInPx)
            }
        }
    }
    
    // MARK: - MISC:
    private func appendDate(forIndex index: Int) {
        let startDateTime = date.dateByAppendingSecs(parentView.applyedTimeInterval.rawValue * index, calendar: parentView.calendar)
        let newDateInterval = CDateInterval(start: startDateTime, duration: TimeInterval(parentView.applyedTimeInterval.rawValue))
        parentView.onApply(newDateInterval, forIndex: NSNumber(value: index))
    }
    
}
