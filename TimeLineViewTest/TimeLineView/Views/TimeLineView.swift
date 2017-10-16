//
//  TimeLineView.swift
//  TimeScrollViewTest
//
//  Created by Dimitry Panychyk on 10/1/17.
//  Copyright © 2017 d'Man. All rights reserved.
//

import UIKit

class TimeLineView: UIView, ThumbViewPanDelegate, TimeLineViewSyncManagerDelegate {
    
    var timeLineViewAppearance = TimeLineDefaultAppearance()
    
    weak var delegate: TimeLineViewDelegate?
    weak var dataSource: TimeLineViewDataSource? {
        didSet {
            reloadData()
        }
    }
    
    weak var weakReference: TimeLineView? {
        return self
    }
    
    private var date: Date {
        return Date(timeInterval: TimeInterval(TimeZone.current.secondsFromGMT()), since: Date()).dateWithZeroHourAndMinute(defaultCalendar)!
    }
    
    private var startPointOffset: Int {
        return Int(round((timeLineViewAppearance.tickMarkWidth)/2))
    }
    
    let oneDayInSec = 86400 // 24*60*60
    
    private lazy var defaultCalendar: Calendar = {
        var cal = Calendar.current
        cal.timeZone = TimeZone(secondsFromGMT: 0)!
        return cal
    }()
    
    // DataSource:
    var isHiddenThumbView = false {
        didSet {
            thumbView.isHidden = isHiddenThumbView
        }
    }
    
    var syncManager: TimeLineViewSyncManager? {
        willSet {
            if let index = syncManager?.listeners.index(where: { $0 === weakReference }) {
                syncManager?.listeners.remove(at: index)
            }
        }
        didSet {
            syncManager?.listeners.append(weakReference)
        }
    }
    
    private(set) var allowIntersectWithSelectedTimeInterval = false
    
    private(set) var maxAppliableTimeIntervalInSecs = 0
    
    private(set) var applyedTimeInterval: CTimeIntervals = .mins30
    
    var timeLineViewModel = CTimeLineViewModel() {
        didSet {
            invalidate()
        }
    }
    
    var intervalStepInPx: CGFloat {
        get {
            switch self.applyedTimeInterval {
            case .mins15:
                return timeLineViewAppearance.mins15StepPx
            case .mins30:
                return timeLineViewAppearance.mins30StepPx
            case .mins60:
                return timeLineViewAppearance.mins60StepPx
            default:
                preconditionFailure("IllegalStateExeption")
            }
        }
    }
    
    var isEnableTapGesture: Bool = true {
        didSet {
            onTimeSectionTapGesture.isEnabled = isEnableTapGesture
        }
    }
    
    // Subviews:
    lazy var thumbView: ThumbView = {
        let thumbView = ThumbView()
        thumbView.timeLineViewAppearance = timeLineViewAppearance
        thumbView.setSize(width: timeLineViewAppearance.thumbSize.width,
                          height: timeLineViewAppearance.thumbSize.height)
        thumbView.delegate = self
        thumbView.isHidden = isHiddenThumbView
        addSubview(thumbView)
        return thumbView
    }()
    
    lazy var selectedTimeIntervalView: SelectedTimeIntervalView = {
        let selectedTimeIntervalView = SelectedTimeIntervalView()
        selectedTimeIntervalView.timeLineViewAppearance = timeLineViewAppearance
        insertSubview(selectedTimeIntervalView, belowSubview: thumbView)
        return selectedTimeIntervalView
    }()
    
    var disabledIndexMap = [Int : Bool]()
    var timeSectorsMap   = [NSNumber : CDateInterval]()
    
    lazy var onTimeSectionTapGesture: UITapGestureRecognizer = {
        let onTimeSectionTapGesture = UITapGestureRecognizer(target: self, action: #selector(onTimeSectionTapAction(_:)))
        return onTimeSectionTapGesture
    }()
    
    private var availableRangeIntervalForIndexMap = [NSNumber : SelectedTimeIntervalScope]()
    
    // MARK: - Init:
    
    convenience init(parent: UIView) {
        self.init()
        parent.addSubview(self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        appearance()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        appearance()
    }
    
    // Appearance
    func appearance() {
        backgroundColor = .white
        addGestureRecognizer(onTimeSectionTapGesture)
    }
    
    // MARK: - Layout:
    func invalidate() {
        let canvasFrame = CGRect(origin: bounds.origin, size: timeLineContentSize())
        frame = canvasFrame
        setNeedsDisplay()
    }
    
    func invalidateSelectedTimeInterval(minX: CGFloat, maxX: CGFloat, timeInterval: CDateInterval) {
        hideSelectedTimeIntervalView(false)
        timeLineViewModel.selectedTimeInterval = timeInterval
        selectedTimeIntervalView.frame = trackViewRect(minX: minX, maxX: maxX)
        thumbView.setCenter(x: maxX, y: selectedTimeIntervalView.frame.midY)
        
        // calc intersection with other reservations
        let index = indexOfDate(timeInterval.startDate)
        if let scope = availableRangeIntervalForIndexMap[NSNumber(integerLiteral: index)] {
            let offset = timeLineViewAppearance.tickMarkWidth
            let isIntersectReservations = maxX > (scope.maxValueX + offset)
            applySelectedViewIntersectStyle(isIntersectReservations)
        } else {
            applySelectedViewIntersectStyle(true)
        }
    }
    
    func timeLineContentSize() -> CGSize {
        let contentSize = CGSize(width: (CGFloat(oneDayInSec/applyedTimeInterval.rawValue) * intervalStepInPx) + timeLineViewAppearance.tickMarkWidth, height: timeLineViewAppearance.timeLineViewHeight)
        return contentSize
    }
    
    func reloadData() {
        if let dataSource = dataSource {
            applyedTimeInterval = dataSource.step(for: self)
            allowIntersectWithSelectedTimeInterval = dataSource.timeIntersectWithReservations(for: self)
            maxAppliableTimeIntervalInSecs = dataSource.maxAppliableTimeIntervalInSecs(for: self)
        }
        invalidate()
    }
    
    // MARK: - Draw:
    override func draw(_ rect: CGRect) {
        drawSeparatorsAndTimeTitles(in: rect)
        drawUnavailableSectors(on: rect)
        drawReservations(on: rect)
        setupAvailableRangeIntervals(in: rect)
        drawSelectedTimeInterval(on: rect)
    }
    
    //Separators:
    func drawSeparatorsAndTimeTitles(in rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.setLineWidth(timeLineViewAppearance.tickMarkWidth)
        for xOrigin in stride(from: startPointOffset, through: Int(rect.width), by: Int(intervalStepInPx)) {
            let index = xOrigin/Int(intervalStepInPx)
            
            appendDate(forIndex: index)
            if xOrigin == Int(rect.width) &&
                (timeLineViewAppearance.tickMarkWidth.truncatingRemainder(dividingBy: 2.0)) != 0 {
                let newX = CGFloat(xOrigin - Int(round((timeLineViewAppearance.tickMarkWidth)/2)))
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
        var height: CGFloat = timeLineViewAppearance.tickMark60minsHeight
        if index > 0 {
            switch applyedTimeInterval {
            case .mins15:
                if CGFloat(index).truncatingRemainder(dividingBy: 2.0) != 0 {
                    height = timeLineViewAppearance.tickMark15minsHeight
                } else if CGFloat(index/2).truncatingRemainder(dividingBy: 2.0) != 0 {
                    height = timeLineViewAppearance.tickMark30minsHeight
                }
            case .mins30:
                if CGFloat(index).truncatingRemainder(dividingBy: 2.0) != 0 {
                    height = timeLineViewAppearance.tickMark30minsHeight
                }
            case .mins60:
                break
            }
        }
        let yOrigin = rect.height - height
        if height == timeLineViewAppearance.tickMark60minsHeight {
            if let dateTime = timeSectorsMap[NSNumber(value: index)] {
                drawTimeText(dateTime.startDate.shortHoursString(defaultCalendar),
                         at: CGPoint(x: (xOrigin + 6.0), y: yOrigin))
            }
        }

        context?.setStrokeColor(timeLineViewAppearance.tickMarkColor.cgColor)
        context?.move(to: CGPoint(x: xOrigin, y: yOrigin))
        context?.addLine(to: CGPoint(x: xOrigin, y: rect.height))
        context?.strokePath()

    }
    
    func drawTimeText(_ text: String, at point: CGPoint) {
        let attributedTimeString = text.attributedString(font:      timeLineViewAppearance.timeLabelAttributes.font,
                                                         charSpace: Float(timeLineViewAppearance.timeLabelAttributes.charSpace),
                                                         tintColor: timeLineViewAppearance.timeLabelAttributes.color)
        attributedTimeString.draw(at: point)
    }
    
    //Unavailable:
    func drawUnavailableSectors(on rect: CGRect) {
        for dateInterval in timeLineViewModel.unavailableTimeIntervalsList {
            let fromSectorIndex = indexOfDate(dateInterval.startDate)
            let toSectorIndex   = indexOfDate(dateInterval.endDate)
            for sectorIndex in stride(from: fromSectorIndex, to: toSectorIndex, by: 1) {
                // Set sector as Unavailable
                disabledIndexMap[sectorIndex] = true
                //
                let xOrigin = CGFloat(sectorIndex) * intervalStepInPx
                let r = CGRect(origin: CGPoint(x: CGFloat(xOrigin),
                                               y: rect.height - timeLineViewAppearance.unavailableZoneHeight),
                               size: CGSize(width: intervalStepInPx,
                                            height: timeLineViewAppearance.unavailableZoneHeight))
                timeLineViewAppearance.unavailableZoneImage?.draw(in: r)
                UIColor(red: 241/255, green: 241/255, blue: 241/255, alpha: 0.6).setFill()
                UIRectFillUsingBlendMode(r, .multiply)
            }
        }
    }

    //Reserved:
    func drawReservations(on rect: CGRect) {
        let reservations = timeLineViewModel.reservedTimeIntervalsList
        if reservations.count > 0 {
            var xOrigin = startPointOffset
            
            let reservationsMutable = NSMutableArray(array: reservations)
            
            while xOrigin <= Int(rect.width) {
                let index = self.convertToIndex(CGFloat(xOrigin))
                if reservationsMutable.count > 0 {
                    for reservation in reservationsMutable {
                        if let reservation = (reservation as? ReservationModel),
                        let dateTime = timeSectorsMap[NSNumber(value: index)],
                            reservation.reservationTimeInterval.startDate == dateTime.startDate
                            //                            && reservation.reservationTimeInterval.duration >= TimeInterval(parentView.applyedTimeInterval.rawValue)
                        {
                            let reservationView = ReservationView(reservation)
                            reservationView.timeLineViewAppearance = timeLineViewAppearance
                            // Set sectors as Unavailable
                            let fromIndex = indexOfDate(reservation.reservationTimeInterval.startDate)
                            let endIndex  = indexOfDate(reservation.reservationTimeInterval.endDate)
                            for sectorIndex in stride(from: fromIndex, to: endIndex, by: 1) {
                                disabledIndexMap[sectorIndex] = true
                            }
                            //
                            let width = convertToWidth(reservation.reservationTimeInterval)
                            reservationView.frame = CGRect(x: self.xOrigin(for: fromIndex),
                                                           y: rect.height - reservationView.timeLineViewAppearance.reservationsViewHeight,
                                                           width: width - timeLineViewAppearance.tickMarkWidth,
                                                           height: reservationView.timeLineViewAppearance.reservationsViewHeight)
                            self.addSubview(reservationView)
                            
                            reservationsMutable.remove(reservation)
                            xOrigin += Int(width)
                            break
                        } else {
                            xOrigin += Int(intervalStepInPx)
                            break
                        }
                    }
                } else {
                    break
                }
            }
        }
    }
    
    //SelectedTimeInterval:
    func drawSelectedTimeInterval(on rect: CGRect) {
        if let selectedTimeInterval = timeLineViewModel.selectedTimeInterval {
            hideSelectedTimeIntervalView(false)
            let fromSectorIndex = indexOfDate(selectedTimeInterval.startDate)
            let throughSelectedIndex = indexOfDate(selectedTimeInterval.endDate)
            var isIntersectReservedSection = false
            for selectedIndex in fromSectorIndex...throughSelectedIndex {
                if let isDisabled = disabledIndexMap[selectedIndex],
                    isDisabled == true {
                    isIntersectReservedSection = true
                    break
                }
            }
            let xOrigin = CGFloat(Int(CGFloat(fromSectorIndex) * intervalStepInPx))
            let width = convertToWidth(selectedTimeInterval)

            selectedTimeIntervalView.frame = trackViewRect(minX: xOrigin, maxX: (xOrigin + width))
            thumbView.setCenter(x: (xOrigin + width), y: selectedTimeIntervalView.frame.midY)
            if isIntersectReservedSection {
                applySelectedViewIntersectStyle(true)
            }
        } else {
            hideSelectedTimeIntervalView(true)
        }
    }
    
    func hideSelectedTimeIntervalView(_ hide: Bool) {
        selectedTimeIntervalView.isHidden = hide
        if !isHiddenThumbView { thumbView.isHidden = hide }
    }
    
    // MARK: - Math:
    private func setupAvailableRangeIntervals(in rect: CGRect) {
        // find allowed indexs
        var allowedIndexsList = [Int]()
        for indexNumber in timeSectorsMap.keys {
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
                    let minValueX: CGFloat = xOrigin(for: groupedIndexs.min() ?? 0)
                    let maxValueX: CGFloat = xOrigin(for: groupedIndexs.max() ?? 0) + intervalStepInPx
                    availableRangeIntervalForIndexMap[NSNumber(value: index)] =
                        SelectedTimeIntervalScope(minValueX: minValueX,
                                                  maxValueX: maxValueX)
                }
            }
        }
    }
    
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
        return super.hitTest(point, with: event)
    }
    
    //MARK: - ThumbViewPanDelegate:
    var allowedSelectionScope: SelectedTimeIntervalScope? {
        if let selectedTimeInterval = timeLineViewModel.selectedTimeInterval {
            if allowIntersectWithSelectedTimeInterval == false {
                // need to set scope limit [min value -|- max value]
                let fromSectorIndex = indexOfDate(selectedTimeInterval.startDate)
                let selectedTimeIntervalScope = availableRangeIntervalForIndexMap[NSNumber(integerLiteral: fromSectorIndex)]
                return selectedTimeIntervalScope
            } else {
                return nil
            }
        }
        return nil
    }
    
    var timeIntervalScope: SelectedTimeIntervalScope {
        let maxTimeIntervalInSecs = maxAppliableTimeIntervalInSecs
        if let selectedTimeInterval = timeLineViewModel.selectedTimeInterval {
            let width = (CGFloat(maxTimeIntervalInSecs/applyedTimeInterval.rawValue) * intervalStepInPx)
            let minValueX = convertToRect(selectedTimeInterval).minX + intervalStepInPx
            let maxValueX = convertToRect(selectedTimeInterval).minX + width
            return SelectedTimeIntervalScope(minValueX: minValueX,
                                             maxValueX: maxValueX)
        }
        return SelectedTimeIntervalScope.zero()
    }
    
    func thumbView(_ thumbView: ThumbView, didChangePoint point: CGPoint) -> (Void) {
        if let selectedTimeInterval = timeLineViewModel.selectedTimeInterval {
            invalidateSelectedTimeInterval(minX: selectedTimeIntervalView.frame.minX, maxX: point.x, timeInterval: selectedTimeInterval)
            if let syncManager = syncManager {
                syncManager.notifyListenersChangeThumbViewLocation(thumbView,
                                                                   minX: selectedTimeIntervalView.frame.minX,
                                                                   maxX: point.x,
                                                                   timeInterval: selectedTimeInterval)
            }
        }
    }
    
    func thumbView(_ thumbView: ThumbView, didFinishScrollingWithPoint point: CGPoint) -> (Void) {
        let truncRemainder = point.x.truncatingRemainder(dividingBy: intervalStepInPx)
        let subtraction = intervalStepInPx - truncRemainder
        // round to greater
        var newPointX = point.x + subtraction
        if subtraction >= intervalStepInPx/2 {
            // round to lesser
            newPointX = point.x - truncRemainder
        }
        let newEndPoint = CGPoint(x: newPointX,
                                  y: point.y)
        let newSize = CGSize(width: newEndPoint.x - selectedTimeIntervalView.frame.origin.x,
                             height: selectedTimeIntervalView.frame.height)
        let newRect = CGRect(origin: selectedTimeIntervalView.frame.origin, size: newSize)
        let newTimeInterval = convertToTimeInterval(newRect)
        invalidateSelectedTimeInterval(minX: selectedTimeIntervalView.frame.minX,
                                       maxX: newPointX,
                                       timeInterval: newTimeInterval)
        delegate?.timeLineView(self, onSelectedTimeIntervalChange: newTimeInterval)
        if let syncManager = syncManager {
            syncManager.notifyListenersChangeThumbViewLocation(thumbView,
                                                               minX: selectedTimeIntervalView.frame.minX,
                                                               maxX: newPointX,
                                                               timeInterval: newTimeInterval)
        }
    }
    
    // MARK: - TimeLineViewSyncManagerDelegate:
    
    func onChangeThumbLocation(_ thumbView: ThumbView, minX: CGFloat, maxX: CGFloat, timeInterval: CDateInterval) {
        if self.thumbView !== thumbView {
            invalidateSelectedTimeInterval(minX: minX,
                             maxX: maxX,
                             timeInterval: timeInterval)
        }
    }
    
    func onChangeTimeInterval(_ timeLineView: TimeLineView, timeInterval: CDateInterval) {
        if timeLineView !== self {
            let minX = xOrigin(for: indexOfDate(timeInterval.startDate))
            let maxX = minX + convertToWidth(timeInterval)
            invalidateSelectedTimeInterval(minX: minX,
                                           maxX: maxX,
                                           timeInterval: timeInterval)
        }
    }
    
    
    // MARK: - TapGesture:
    
    @objc fileprivate func onTimeSectionTapAction(_ gesture: UITapGestureRecognizer) {
        let points = gesture.location(in: self)
        let index = convertToIndex(points.x)
        let pointOnThumbView = self.convert(points, to: thumbView)
        if let scope = availableRangeIntervalForIndexMap[NSNumber(integerLiteral: index)],
            let sectorTimeInterval = timeSectorsMap[NSNumber(integerLiteral: index)],
            !thumbView.hitAreaBounds.contains(pointOnThumbView) {
            let newDuration = calcNewDuration(in: scope,
                                              for: index,
                                              with: timeLineViewModel.selectedTimeInterval?.duration)
            let minX = xOrigin(for: index)
            let maxX = minX + convertToWidth(newDuration)
            let newTimeInterval = CDateInterval(start: sectorTimeInterval.startDate, duration: newDuration)
            invalidateSelectedTimeInterval(minX: minX, maxX: maxX, timeInterval: newTimeInterval)
            delegate?.timeLineView(self, onSelectedTimeIntervalChange: newTimeInterval)
            if let syncManager = syncManager {
                syncManager.notifyListenersOnChangeTimeInterval(in: self, newTimeInterval: newTimeInterval)
            }
        }
    }
    
    // MARK: - Private:
    fileprivate func appendDate(forIndex index: Int) {
        let startDateTime = date.dateByAppendingSecs(applyedTimeInterval.rawValue * index, calendar: defaultCalendar)
        let newDateInterval = CDateInterval(start: startDateTime, duration: TimeInterval(applyedTimeInterval.rawValue))
        timeSectorsMap[NSNumber(value: index)] = newDateInterval
    }
    
    fileprivate func applySelectedViewIntersectStyle(_ isIntersect: Bool) {
        thumbView.setIntersectState(isIntersect)
        selectedTimeIntervalView.setIntersectState(isIntersect)
    }
    
    //returns the rect for the track view between the lower and upper values based on SelectedTimeIntervalView object
    fileprivate func trackViewRect(minX: CGFloat, maxX: CGFloat) -> CGRect {
        let rect = CGRect(x: minX,
                          y: self.frame.height - selectedTimeIntervalView.timeLineViewAppearance.selectedTimeViewHeight,
                          width: maxX - minX,
                          height: selectedTimeIntervalView.timeLineViewAppearance.selectedTimeViewHeight)
        return rect
    }
    
    fileprivate func calcNewDuration(in newRange: SelectedTimeIntervalScope, for index: Int, with oldDuration: TimeInterval?) -> TimeInterval {
        if let oldDuration = oldDuration {
            let oldWidth = convertToWidth(oldDuration)
            let xOriginOfIndex = xOrigin(for: index)
            var xMaxPoint = xOriginOfIndex + oldWidth
            if xMaxPoint <= newRange.maxValueX {
                return oldDuration
            } else {
                repeat {
                    xMaxPoint -= intervalStepInPx
                    if xMaxPoint <= newRange.maxValueX {
                        return convertToDuration(xMaxPoint - xOriginOfIndex)
                    }
                } while (xMaxPoint - xOriginOfIndex) > intervalStepInPx
            }
            assert(false, "AssertionError")
            return TimeInterval(applyedTimeInterval.rawValue)
        } else {
            return TimeInterval(applyedTimeInterval.rawValue)
        }
    }
    
    fileprivate func convertToTimeInterval(_ rect: CGRect) -> CDateInterval {
        let startIndex = Int(rect.minX / intervalStepInPx)
        var endIndex = Int(rect.maxX / intervalStepInPx)
        if endIndex > 0 {
            endIndex -= 1
        }
        let dateInterval = CDateInterval(start: timeSectorsMap[NSNumber(value: startIndex)]!.startDate,
                                         end: timeSectorsMap[NSNumber(value: endIndex)]!.endDate)
        return dateInterval
    }
    
    fileprivate func convertToRect(_ timeInterval: CDateInterval) -> CGRect {
        let xOrigin = CGFloat(indexOfDate(timeInterval.startDate)) * intervalStepInPx
        let width   = convertToWidth(timeInterval) - timeLineViewAppearance.tickMarkWidth
        let rect    = CGRect(x: xOrigin, y: 0, width: width, height: 50)
        return rect
    }
    
    fileprivate func indexOfDate(_ date: Date) -> Int {
        let index = date.sinceToday(defaultCalendar)/applyedTimeInterval.rawValue
        return index
    }
    
    fileprivate func convertToDuration(_ width: CGFloat) -> TimeInterval {
        let newDuration = TimeInterval((width / intervalStepInPx) * CGFloat(applyedTimeInterval.rawValue))
        return newDuration
    }
    
    fileprivate func convertToWidth(_ duration: TimeInterval) -> CGFloat {
        let width = CGFloat(duration/TimeInterval(applyedTimeInterval.rawValue)) * intervalStepInPx + CGFloat(startPointOffset)
        return width
    }
    
    fileprivate func convertToWidth(_ timeInterval: CDateInterval) -> CGFloat {
        return convertToWidth(timeInterval.duration)
    }
    
    fileprivate func convertToIndex(_ xOrigin: CGFloat) -> Int {
        let index = Int((xOrigin - CGFloat(startPointOffset))/intervalStepInPx)
        let maxIndex = getMaxIndex()
        if index > maxIndex { return maxIndex }
        return index
    }
    
    fileprivate func xOrigin(for index: Int) -> CGFloat {
        let maxIndex = getMaxIndex()
        if index > maxIndex { return CGFloat(maxIndex) * intervalStepInPx }
        return CGFloat(index) * intervalStepInPx
    }
    
    fileprivate func getMaxIndex() -> Int {
        if let maxIndex = timeSectorsMap.keys.max(by: { $0.intValue < $1.intValue })?.intValue {
            return maxIndex > 0 ? maxIndex - 1 : maxIndex
        }
        return 0
    }
    
}
