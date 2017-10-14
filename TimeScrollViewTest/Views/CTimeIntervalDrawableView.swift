//
//  CTimeScrollViewCanvas.swift
//  TimeScrollViewTest
//
//  Created by Dimitry Panychyk on 10/1/17.
//  Copyright © 2017 d'Man. All rights reserved.
//

import UIKit
import NotificationCenter

class CTimeIntervalDrawableView: UIView, CThumbViewPanDelegate, CTimeIntervalDrawableViewProtocol, TimeScrollViewSyncManagerDelegate {
    
    private(set) weak var parentView: CTimeIntervalScrollView!
    
    lazy var date: Date = {
        return Date().dateWithZeroHourAndMinute(self.parentView.calendar)!
    }()
    
    // Subviews:
    lazy var thumbView: CThumbView = {
        let thumbView = CThumbView()
        thumbView.delegate = self
        thumbView.isHidden = !parentView.isAllowThumbView
        addSubview(thumbView)
        return thumbView
    }()
    
    lazy var selectedTimeIntervalView: CSelectedTimeIntervalView = {
        let selectedTimeIntervalView = CSelectedTimeIntervalView()
        addSubview(selectedTimeIntervalView)
        return selectedTimeIntervalView
    }()
    
    var startPoint: Int {
        return Int(round((parentView.separatorWidth)/2))
    }
    
    var disabledIndexMap = [Int : Bool]()
    
    private var availableRangeIntervalForIndexMap = [NSNumber : SelectedTimeIntervalScope]()
    
    // MARK: - Lifecycle:
    convenience init(_ parent: CTimeIntervalScrollView) {
        self.init()
        backgroundColor = .white
        parentView = parent
    }
    
    // MARK: - Draw:
    override func draw(_ rect: CGRect) {
        drawSeparatorsAndTimeTitles(in: rect)
        drawUnavailableSectors(on: rect)
        drawReservations(on: rect)
        setupAvailableRangeIntervals(in: rect)
        drawSelectedTimeInterval(on: rect)
    }
    
    // MARK: - Separators:
    func drawSeparatorsAndTimeTitles(in rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.setLineWidth(parentView.separatorWidth)
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
    func drawUnavailableSectors(on rect: CGRect) {
        for dateInterval in parentView.timeIntervalScrollViewModel.unavailableTimeIntervalsList {
            let fromSectorIndex = indexOfDate(dateInterval.startDate)
            let toSectorIndex   = indexOfDate(dateInterval.endDate)
            for sectorIndex in stride(from: fromSectorIndex, to: toSectorIndex, by: 1) {
                // Set sector as Unavailable
                disabledIndexMap[sectorIndex] = true
                //
                let xOrigin = CGFloat(sectorIndex) * parentView.intervalStepInPx
                let r = CGRect(origin: CGPoint(x: CGFloat(xOrigin),
                                               y: rect.height - parentView.unavailableSectorImageHeight),
                               size: CGSize(width: parentView.intervalStepInPx,
                                            height: parentView.unavailableSectorImageHeight))
                setUnavailable(in: r, at: sectorIndex)
            }
        }
    }
    
    func setUnavailable(in rect: CGRect, at index: Int) {
        parentView.unavailableSectorImage?.draw(in: rect)
        UIColor(red: 241/255, green: 241/255, blue: 241/255, alpha: 0.6).setFill()
        UIRectFillUsingBlendMode(rect, .multiply)
    }

    // MARK: - Reserved:
    func drawReservations(on rect: CGRect) {
        let reservations = parentView.timeIntervalScrollViewModel.reservedTimeIntervalsList
        if reservations.count > 0 {
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
                            // Set sectors as Unavailable
                            let fromIndex = indexOfDate(reservation.reservationTimeInterval.startDate)
                            let endIndex  = indexOfDate(reservation.reservationTimeInterval.endDate)
                            for sectorIndex in stride(from: fromIndex, to: endIndex, by: 1) {
                                disabledIndexMap[sectorIndex] = true
                            }
                            //
                            let width = convertToWidth(reservation.reservationTimeInterval) - CGFloat(parentView.separatorWidth)
                            reservationView.frame = CGRect(x: CGFloat(xOrigin),
                                                           y: rect.height - reservationView.contentHeight,
                                                           width: width,
                                                           height: reservationView.contentHeight)
                            self.addSubview(reservationView)
                            
                            reservationsMutable.remove(reservation)
                            xOrigin += Int(width)
                            break
                        }
                    }
                }
                xOrigin += Int(parentView.intervalStepInPx)
            }
        }
    }
    
    // MARK: - SelectedTimeIntervalView:
    func drawSelectedTimeInterval(on rect: CGRect) {
        if let selectedTimeInterval = parentView.timeIntervalScrollViewModel.selectedTimeInterval {
            let fromSectorIndex = indexOfDate(selectedTimeInterval.startDate)
            
            if parentView.allowIntersectWithSelectedTimeInterval == false {
                // need to set scope limit [min value -|- max value]
                let selectedTimeIntervalScope = availableRangeIntervalForIndexMap[NSNumber(integerLiteral: fromSectorIndex)]
                selectionScope = selectedTimeIntervalScope
            } else {
                selectionScope = nil
            }
            
            let xOrigin = CGFloat(Int(CGFloat(fromSectorIndex) * parentView.intervalStepInPx))

            let width = convertToWidth(selectedTimeInterval)// - CGFloat(parentView.separatorWidth)
            invalidateLayout(minX: xOrigin, maxX: (xOrigin + width), timeInterval: selectedTimeInterval)
        }
    }
    
    // MARK: - MISC:
    private func appendDate(forIndex index: Int) {
        let startDateTime = date.dateByAppendingSecs(parentView.applyedTimeInterval.rawValue * index, calendar: parentView.calendar)
        let newDateInterval = CDateInterval(start: startDateTime, duration: TimeInterval(parentView.applyedTimeInterval.rawValue))
        parentView.onApply(newDateInterval, forIndex: NSNumber(value: index))
    }
    
    func setupAvailableRangeIntervals(in rect: CGRect) {
        // find allowed indexs
        var allowedIndexsList = [Int]()
        for indexNumber in parentView.timeSectorsMap.keys {
            let index = indexNumber.intValue
            if self.disabledIndexMap[index] == nil {
                allowedIndexsList.append(index)
            }
        }
        allowedIndexsList.sort(by: {$0 < $1})
        // group allowed index's
        let groupedDict = groupAvailableIndexs(allowedIndexsList)
        for key in groupedDict.keys.sorted() {
            if let groupedIndexs = groupedDict[key] {
                for index in groupedIndexs {
                    let minValueX: CGFloat = CGFloat(groupedIndexs.min() ?? 0) * parentView.intervalStepInPx
                    let maxValueX: CGFloat = CGFloat(groupedIndexs.max() ?? 0) * parentView.intervalStepInPx + parentView.intervalStepInPx
                    availableRangeIntervalForIndexMap[NSNumber(value: index)] =
                        SelectedTimeIntervalScope(minValueX: minValueX,
                                                  maxValueX: maxValueX)
                }
            }
        }
    }
    
    // MARK: - Math:
    
    private func groupAvailableIndexs(_ availableIndexsList: [Int]) -> [Int : [Int]] {
        var groupArray = [Int : [Int]]()
        if availableIndexsList.count > 0 {
            var entryIndex = availableIndexsList[0]
            var key = 0
            groupArray[key] = [entryIndex]
            for index in availableIndexsList {
                if index == entryIndex {
                    continue
                }
                if index - entryIndex == 1 {
                    groupArray[key]?.append(index)
                } else {
                    key += 1
                    groupArray[key] = [index]
                }
                entryIndex = index
            }
        }
        return groupArray
    }
    
    // MARK: - HitTest:
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        // perform hit test on ThumbView frame
        if !thumbView.isHidden {
            let pointOnThumbView = self.convert(point, to: thumbView)
            
            if thumbView.hitAreaBounds.contains(pointOnThumbView) {
                return thumbView
            }
        }
        let view = super.hitTest(point, with: event)
        if let view = view, view.isEqual(self) {
            return nil
        }
        return view
    }
    
    //MARK: - CThumbViewPanDelegate:
    var selectionScope: SelectedTimeIntervalScope?
    
    var timeIntervalScope: SelectedTimeIntervalScope {
        let maxTimeIntervalInSecs = parentView.maxAppliableTimeIntervalInSecs
        if let selectedTimeInterval = parentView.timeIntervalScrollViewModel.selectedTimeInterval {
            let width = (CGFloat(maxTimeIntervalInSecs/parentView.applyedTimeInterval.rawValue) * parentView.intervalStepInPx)
            let minValueX = convertToRect(selectedTimeInterval).minX + parentView.intervalStepInPx
            let maxValueX = convertToRect(selectedTimeInterval).minX + width
            return SelectedTimeIntervalScope(minValueX: minValueX,
                                             maxValueX: maxValueX)
        }
        return SelectedTimeIntervalScope.zero()
    }
    
    func thumbView(_ thumbView: CThumbView, didChangePoint point: CGPoint) -> (Void) {
        if let selectedTimeInterval = parentView.timeIntervalScrollViewModel.selectedTimeInterval {
            invalidateLayout(minX: selectedTimeIntervalView.frame.minX, maxX: point.x, timeInterval: selectedTimeInterval)
            if parentView.registerToChangeSelectedTimeIntervalsSimultaneouslyWithOtherViews {
                let syncManager = TimeScrollViewSyncManager.shared
                syncManager.notifyListeners(minX: selectedTimeIntervalView.frame.minX,
                                            maxX: point.x,
                                            thumbView: thumbView,
                                            timeInterval: selectedTimeInterval)
            }
        }
    }
    
    func thumbView(_ thumbView: CThumbView, didFinishScrollingWithPoint point: CGPoint) -> (Void) {
        let truncRemainder = point.x.truncatingRemainder(dividingBy: parentView.intervalStepInPx)
        let subtraction = parentView.intervalStepInPx - truncRemainder
        let xOffset = CGFloat(startPoint)
        // round to greater
        var newPointX = point.x + subtraction
        if subtraction >= parentView.intervalStepInPx/2 {
            // round to lesser
            newPointX = point.x - truncRemainder
        }
        let newEndPoint = CGPoint(x: newPointX,
                                  y: point.y)
        let newSize = CGSize(width: newEndPoint.x - selectedTimeIntervalView.frame.origin.x,
                             height: selectedTimeIntervalView.frame.height)
        let newRect = CGRect(origin: selectedTimeIntervalView.frame.origin, size: newSize)
        let newTimeInterval = convertToTimeInterval(newRect)
        invalidateLayout(minX: selectedTimeIntervalView.frame.minX,
                         maxX: newPointX + xOffset,
                         timeInterval: newTimeInterval)
        if parentView.registerToChangeSelectedTimeIntervalsSimultaneouslyWithOtherViews {
            let syncManager = TimeScrollViewSyncManager.shared
            syncManager.notifyListeners(minX: selectedTimeIntervalView.frame.minX,
                                        maxX: newPointX + xOffset,
                                        thumbView: thumbView,
                                        timeInterval: newTimeInterval)
        }
    }
    
    // MARK: - CTimeIntervalDrawableViewProtocol:

    func onSelectionEvent(with index: Int, andPoint point: CGPoint) {
//        let pointOnThumbView = self.convert(point, to: thumbView)
//        if let scope = availableRangeIntervalForIndexMap[NSNumber(integerLiteral: index)],
//            let sectorTimeInterval = parentView.timeSectorsMap[NSNumber(integerLiteral: index)],
//            !thumbView.hitAreaBounds.contains(pointOnThumbView) {
//            let newDuration = calcNewDuration(in: scope,
//                                              for: index,
//                                              with: parentView.timeIntervalScrollViewModel.selectedTimeInterval?.duration)
//            let newTimeInterval = CDateInterval(start: sectorTimeInterval.startDate, duration: newDuration)
//            parentView.timeIntervalScrollViewModel.selectedTimeInterval = newTimeInterval
//            drawSelectedTimeInterval(on: self.bounds)
//        }
    }
    
    // MARK: - TimeScrollViewSyncManagerDelegate:
    
    func onChangeThumbLocation(minX: CGFloat, maxX: CGFloat, thumbView: CThumbView, timeInterval: CDateInterval) {
        if self.thumbView != thumbView {
            invalidateLayout(minX: minX,
                             maxX: maxX,
                             timeInterval: timeInterval)
        }
    }
    
    // MARK: - Private:
    
    fileprivate func invalidateLayout(minX: CGFloat, maxX: CGFloat, timeInterval: CDateInterval) {
        parentView.timeIntervalScrollViewModel.selectedTimeInterval = timeInterval
        selectedTimeIntervalView.frame = trackViewRect(minX: minX, maxX: maxX)
        thumbView.setCenter(x: maxX, y: selectedTimeIntervalView.frame.midY)
        // calc intersection with other reservations
        if parentView.allowIntersectWithSelectedTimeInterval {
            let index = indexOfDate(timeInterval.startDate)
            if let scope = availableRangeIntervalForIndexMap[NSNumber(integerLiteral: index)] {
                let offset = parentView.separatorWidth
                if maxX > (scope.maxValueX + offset) {
                    // apply intersect color for selected time interval view
                    selectedTimeIntervalView.setIntersectState(true)
                } else {
                    selectedTimeIntervalView.setIntersectState(false)
                }
            }
        }
    }
    
    //returns the rect for the track view between the lower and upper values based on CSelectedTimeIntervalView object
    private func trackViewRect(minX: CGFloat, maxX: CGFloat) -> CGRect {
        
        let rect = CGRect(x: minX,
                          y: self.frame.height - selectedTimeIntervalView.viewHeight,
                          width: maxX - minX,
                          height: selectedTimeIntervalView.viewHeight)
        return rect
    }
    
    fileprivate func calcNewDuration(in newRange: SelectedTimeIntervalScope, for index: Int, with oldDuration: TimeInterval?) -> TimeInterval {
        if let oldDuration = oldDuration {
            let oldWidth = convertToWidth(oldDuration)
            let xOriginOfIndex = (CGFloat(index) * parentView.intervalStepInPx)
            var xMaxPoint = xOriginOfIndex + oldWidth
            if xMaxPoint <= newRange.maxValueX {
                return oldDuration
            } else {
                repeat {
                    xMaxPoint -= parentView.intervalStepInPx
                    if xMaxPoint <= newRange.maxValueX {
                        return convertToDuration(xMaxPoint - xOriginOfIndex)
                    }
                } while (xMaxPoint - xOriginOfIndex) > parentView.intervalStepInPx
            }
            assert(false, "AssertionError")
            return TimeInterval(parentView.applyedTimeInterval.rawValue)
        } else {
            return TimeInterval(parentView.applyedTimeInterval.rawValue)
        }
    }
    
    fileprivate func convertToTimeInterval(_ rect: CGRect) -> CDateInterval {
        let startIndex = Int(rect.minX / parentView.intervalStepInPx)
        var endIndex = Int(rect.maxX / parentView.intervalStepInPx)
        if endIndex > 0 {
            endIndex -= 1
        }
        let dateInterval = CDateInterval(start: parentView.timeSectorsMap[NSNumber(value: startIndex)]!.startDate,
                                         end: parentView.timeSectorsMap[NSNumber(value: endIndex)]!.endDate)
        return dateInterval
    }
    
    fileprivate func convertToRect(_ timeInterval: CDateInterval) -> CGRect {
        let xOrigin = CGFloat(indexOfDate(timeInterval.startDate)) * parentView.intervalStepInPx
        let width   = convertToWidth(timeInterval) - CGFloat(parentView.separatorWidth)
        let rect = CGRect(x: xOrigin, y: 0, width: width, height: 50)
        return rect
    }
    
    fileprivate func indexOfDate(_ date: Date) -> Int {
        let index = date.sinceToday(parentView.calendar)/parentView.applyedTimeInterval.rawValue
        return index
    }
    
    fileprivate func convertToDuration(_ width: CGFloat) -> TimeInterval {
        let newDuration = TimeInterval((width / parentView.intervalStepInPx) * CGFloat(parentView.applyedTimeInterval.rawValue))
        return newDuration
    }
    
    fileprivate func convertToWidth(_ duration: TimeInterval) -> CGFloat {
        let width = CGFloat(duration/TimeInterval(parentView.applyedTimeInterval.rawValue)) * parentView.intervalStepInPx
        return width
    }
    
    fileprivate func convertToWidth(_ timeInterval: CDateInterval) -> CGFloat {
        return convertToWidth(timeInterval.duration)
    }
    
    fileprivate func convertToIndex(_ xOrigin: CGFloat) -> Int {
        let index = Int(xOrigin/parentView.intervalStepInPx)
        return index
    }
    
    fileprivate func xOrigin(for index: Int) -> CGFloat {
        let xOrigin = CGFloat(index) * parentView.intervalStepInPx
        return xOrigin
    }
    
}
