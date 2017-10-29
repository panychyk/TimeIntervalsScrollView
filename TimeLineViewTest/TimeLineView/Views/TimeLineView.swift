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

    var date: Date!

    private var startPointOffset: Int {
        return Int(round((timeLineViewAppearance.tickMarkWidth)/2))
    }

    static let oneDayInSec = 86400 // 24*60*60

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

    public private(set) var timeLineViewModel: CTimeLineViewModel?
    
    var reservationViews = [ReservationView]()
    
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
                preconditionFailure("IllegalStateException")
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

    internal var availableRangeIntervalForIndexMap = [NSNumber : SelectedTimeIntervalScope]()

    // MARK: - Static:
    
    public static func getTimeLineSize(tickInterval: CTimeIntervals, appearance: TimeLineViewAppearance = TimeLineDefaultAppearance()) -> CGSize {
        var intervalStepInPx: CGFloat!
        switch tickInterval {
        case .mins15:
            intervalStepInPx = appearance.mins15StepPx
        case .mins30:
            intervalStepInPx = appearance.mins30StepPx
        case .mins60:
            intervalStepInPx = appearance.mins60StepPx
        default:
            preconditionFailure("IllegalStateException")
        }
        
        let contentSize = CGSize(width: (CGFloat(oneDayInSec/tickInterval.rawValue) * intervalStepInPx) + appearance.tickMarkWidth + appearance.thumbSize.width/2, height: appearance.timeLineViewHeight)
        
        return contentSize
    }
    
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
        let canvasFrame = CGRect(origin: bounds.origin, size: timeLineSafeAreaRect().size)
        frame = canvasFrame
        setNeedsDisplay()
    }

    func prepareForReuse() {
        for reservationView in reservationViews {
            reservationView.removeFromSuperview()
        }
        reservationViews = []
        date = nil
        disabledIndexMap = [:]
        availableRangeIntervalForIndexMap = [:]
        timeLineViewModel = nil
        syncManager = nil
    }
    
    func invalidateSelectedTimeInterval(minX: CGFloat, maxX: CGFloat, timeInterval: CDateInterval) {
        if timeLineViewModel == nil {
            timeLineViewModel = CTimeLineViewModel()
        }
        timeLineViewModel!.selectedTimeInterval = timeInterval

        hideSelectedTimeIntervalView(false)
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
        let contentSize = CGSize(width: (CGFloat(TimeLineView.oneDayInSec/applyedTimeInterval.rawValue) * intervalStepInPx) + timeLineViewAppearance.tickMarkWidth + timeLineViewAppearance.thumbSize.width/2, height: timeLineViewAppearance.timeLineViewHeight)
        return contentSize
    }

    func timeLineSafeAreaRect() -> CGRect {
        let contentSize = CGSize(width: (CGFloat(TimeLineView.oneDayInSec/applyedTimeInterval.rawValue) * intervalStepInPx) + timeLineViewAppearance.tickMarkWidth, height: timeLineViewAppearance.timeLineViewHeight)
        return CGRect(origin: bounds.origin, size: contentSize)
    }
    
    func reloadData() {
        for reservationView in reservationViews {
            reservationView.removeFromSuperview()
        }
        reservationViews = []
        disabledIndexMap = [:]
        availableRangeIntervalForIndexMap = [:]
        
        if let dataSource = dataSource {
            applyedTimeInterval = dataSource.step(for: self)
            allowIntersectWithSelectedTimeInterval = dataSource.timeIntersectWithReservations(for: self)
            maxAppliableTimeIntervalInSecs = dataSource.maxAppliableTimeIntervalInSecs(for: self)
            timeLineViewModel = dataSource.timeLineViewModelFroView(self)
        }
        invalidate()
    }

    // MARK: - Public:
    
    func xOffsetForDate(_ date: Date) -> CGFloat {
        if self.date.dateWithZeroHourAndMinute(defaultCalendar) == date.dateWithZeroHourAndMinute(defaultCalendar) {
            let index = indexOfDate(date)
            return xOrigin(for: index)
        }
        return CGFloat(startPointOffset)
    }
    
    func convertToWidth(_ duration: TimeInterval) -> CGFloat {
        let width = CGFloat(Int(duration/TimeInterval(applyedTimeInterval.rawValue))) * intervalStepInPx + CGFloat(startPointOffset)
        return width
    }
    
    func convertToWidth(_ timeInterval: CDateInterval) -> CGFloat {
        return convertToWidth(timeInterval.duration)
    }
    
    func dateIntervalFor(index: Int) -> CDateInterval? {
        return timeSectorsMap[NSNumber(value: index)]
    }
    
    // MARK: - Draw:
    override func draw(_ rect: CGRect) {
        precondition(date != nil, "date parameter must not be nil")
        let newRect = timeLineSafeAreaRect()
        drawSeparatorsAndTimeTitles(in: newRect)
        drawUnavailableSectors(on: newRect)
        drawReservations(on: newRect)
        setupAvailableRangeIntervals(in: newRect)
        drawSelectedTimeInterval(on: newRect)
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
        for xOrigin in stride(from: startPointOffset, through: Int(rect.width), by: Int(intervalStepInPx)) {
            let currIndex = xOrigin/Int(intervalStepInPx)
            
            guard let currDateInterval = dateIntervalFor(index: currIndex) else {
                assert(false, "out of date range")
                return
            }
            if isContainsInAvailableTimeIntervals(currDateInterval.startDate) == false {
                disabledIndexMap[currIndex] = true
                //
                let xOrigin = CGFloat(currIndex) * intervalStepInPx
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
        
        guard let timeLineViewModel = timeLineViewModel, timeLineViewModel.reservedTimeIntervalsList.count > 0  else { return }
        
        let reservations = timeLineViewModel.reservedTimeIntervalsList
        var xOrigin = startPointOffset
        
        let reservationsMutable = NSMutableArray(array: reservations)
        while xOrigin <= Int(rect.width) {
            let index = self.convertToIndex(CGFloat(xOrigin))
            if reservationsMutable.count > 0 {
                for reservation in reservationsMutable {
                    if let reservation = (reservation as? TimeLineReservation),
                        let dateTime = timeSectorsMap[NSNumber(value: index)],
                        reservation.startDate == dateTime.startDate
                        //                            && reservation.reservationTimeInterval.duration >= TimeInterval(parentView.applyedTimeInterval.rawValue)
                    {
                        let reservationView = ReservationView(reservation)
                        reservationView.timeLineViewAppearance = timeLineViewAppearance
                        // Set sectors as Unavailable
                        let fromIndex = indexOfDate(reservation.startDate)
                        let endIndex  = indexOfDate(reservation.endDate)
                        for sectorIndex in fromIndex..<endIndex {
                            disabledIndexMap[sectorIndex] = true
                        }
                        //
                        let width = convertToWidth(reservation.endDate.timeIntervalSince(reservation.startDate))
                        reservationView.frame = CGRect(x: self.xOrigin(for: fromIndex),
                                                       y: rect.height - reservationView.timeLineViewAppearance.reservationsViewHeight,
                                                       width: width - timeLineViewAppearance.tickMarkWidth,
                                                       height: reservationView.timeLineViewAppearance.reservationsViewHeight)
                        addSubview(reservationView)
                        reservationViews.append(reservationView)

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

    //SelectedTimeInterval:
    func drawSelectedTimeInterval(on rect: CGRect) {
        guard let timeLineViewModel = timeLineViewModel,
            let selectedTimeInterval = timeLineViewModel.selectedTimeInterval else {
                hideSelectedTimeIntervalView(true)
                return
        }
        hideSelectedTimeIntervalView(false)
        let fromSectorIndex = indexOfDate(selectedTimeInterval.startDate)
        let throughSelectedIndex = indexOfDate(selectedTimeInterval.endDate)
        var isIntersectReservedSection = false
        for selectedIndex in fromSectorIndex..<throughSelectedIndex {
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
    }

    func hideSelectedTimeIntervalView(_ hide: Bool) {
        selectedTimeIntervalView.isHidden = hide
        if !isHiddenThumbView { thumbView.isHidden = hide }
        if !hide {
            bringSubview(toFront: selectedTimeIntervalView)
            bringSubview(toFront: thumbView)
        }
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
                    let minValueX: CGFloat = xOrigin(for: groupedIndexs.min() ?? 0) + CGFloat(startPointOffset)
                    let maxValueX: CGFloat = xOrigin(for: groupedIndexs.max() ?? 0) + intervalStepInPx
                        + CGFloat(startPointOffset)
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
    
    func isContainsInAvailableTimeIntervals(_ date: Date) -> Bool {
        let currDateIndex = indexOfDate(date)
        guard let timeLineViewModel = timeLineViewModel else { return false }
        
        for dateInterval in timeLineViewModel.availableTimeIntervalsList {
            let fromSectorIndex = indexOfDate(dateInterval.startDate)
            let toSectorIndex   = indexOfDate(dateInterval.endDate)
            if fromSectorIndex..<toSectorIndex ~= currDateIndex {
                return true
            }
        }
        return false
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
        if let timeLineViewModel = timeLineViewModel, let selectedTimeInterval = timeLineViewModel.selectedTimeInterval {
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
        if let timeLineViewModel = timeLineViewModel, let selectedTimeInterval = timeLineViewModel.selectedTimeInterval {
            let width = (CGFloat(maxTimeIntervalInSecs/applyedTimeInterval.rawValue) * intervalStepInPx)
            let minValueX = convertToRect(selectedTimeInterval).minX + intervalStepInPx
            let maxValueX = convertToRect(selectedTimeInterval).minX + width
            return SelectedTimeIntervalScope(minValueX: minValueX,
                                             maxValueX: maxValueX)
        }
        return SelectedTimeIntervalScope.zero()
    }

    func thumbView(_ thumbView: ThumbView, didChangePoint point: CGPoint) -> (Void) {
        if let timeLineViewModel = timeLineViewModel, let selectedTimeInterval = timeLineViewModel.selectedTimeInterval {
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
        if timeLineSafeAreaRect().contains(points) {
            let index = convertToIndex(points.x)
            let pointOnThumbView = self.convert(points, to: thumbView)
            if let scope = availableRangeIntervalForIndexMap[NSNumber(integerLiteral: index)],
                let sectorTimeInterval = timeSectorsMap[NSNumber(integerLiteral: index)],
                !thumbView.hitAreaBounds.contains(pointOnThumbView) {
                let newDuration = calcNewDuration(in: scope,
                                                  for: index,
                                                  with: timeLineViewModel?.selectedTimeInterval?.duration)
                let minX = xOrigin(for: index)
                let maxX = minX + convertToWidth(newDuration)
                let newTimeInterval = CDateInterval(start: sectorTimeInterval.startDate, duration: newDuration)
                
                if timeLineViewModel?.selectedTimeInterval != nil {
                    delegate?.timeLineView(self, onSelectedTimeIntervalChange: newTimeInterval)
                } else {
                    delegate?.timeLineView(self, didSelectTime: newTimeInterval)
                }
                
                invalidateSelectedTimeInterval(minX: minX, maxX: maxX, timeInterval: newTimeInterval)
                if let syncManager = syncManager {
                    syncManager.notifyListenersOnChangeTimeInterval(in: self, newTimeInterval: newTimeInterval)
                }
            }
        }
    }

    // MARK: - Private:
    internal func appendDate(forIndex index: Int) {
        let startDateTime = date.dateByAppendingSecs(applyedTimeInterval.rawValue * index, calendar: defaultCalendar)
        let newDateInterval = CDateInterval(start: startDateTime, duration: TimeInterval(applyedTimeInterval.rawValue))
        timeSectorsMap[NSNumber(value: index)] = newDateInterval
    }
    
    internal func applySelectedViewIntersectStyle(_ isIntersect: Bool) {
        thumbView.setIntersectState(isIntersect)
        selectedTimeIntervalView.setIntersectState(isIntersect)
    }

    //returns the rect for the track view between the lower and upper values based on SelectedTimeIntervalView object
    internal func trackViewRect(minX: CGFloat, maxX: CGFloat) -> CGRect {
        let rect = CGRect(x: minX,
                          y: self.frame.height - selectedTimeIntervalView.timeLineViewAppearance.selectedTimeViewHeight,
                          width: maxX - minX,
                          height: selectedTimeIntervalView.timeLineViewAppearance.selectedTimeViewHeight)
        return rect
    }

    internal func calcNewDuration(in newRange: SelectedTimeIntervalScope, for index: Int, with oldDuration: TimeInterval?) -> TimeInterval {
        if let oldDuration = oldDuration {
            let oldWidth = convertToWidth(oldDuration)
            let xOriginOfIndex = xOrigin(for: index)
            var xMaxPoint = xOriginOfIndex + oldWidth
            if xMaxPoint <= newRange.maxValueX {
                return oldDuration
            } else {
                repeat {
                    xMaxPoint -= intervalStepInPx
                    if xMaxPoint <= newRange.maxValueX && xMaxPoint >= intervalStepInPx {
                        return convertToDuration(xMaxPoint - xOriginOfIndex)
                    } else {
                        continue
                    }
                } while (xMaxPoint - xOriginOfIndex) > intervalStepInPx
            }
            assert(false, "AssertionError")
            return TimeInterval(applyedTimeInterval.rawValue)
        } else {
            return TimeInterval(applyedTimeInterval.rawValue)
        }
    }

    internal func convertToTimeInterval(_ rect: CGRect) -> CDateInterval {
        let startIndex = Int(rect.minX / intervalStepInPx)
        var endIndex = Int(rect.maxX / intervalStepInPx)
        if endIndex > 0 {
            endIndex -= 1
        }
        let dateInterval = CDateInterval(start: timeSectorsMap[NSNumber(value: startIndex)]!.startDate,
                                         end: timeSectorsMap[NSNumber(value: endIndex)]!.endDate)
        return dateInterval
    }

    internal func convertToRect(_ timeInterval: CDateInterval) -> CGRect {
        let xOrigin = CGFloat(indexOfDate(timeInterval.startDate)) * intervalStepInPx
        let width   = convertToWidth(timeInterval) - timeLineViewAppearance.tickMarkWidth
        let rect    = CGRect(x: xOrigin, y: 0, width: width, height: 50)
        return rect
    }

    internal func indexOfDate(_ date: Date) -> Int {
        let index = Int(date.timeIntervalSince(self.date.dateWithZeroHourAndMinute(defaultCalendar)!))/applyedTimeInterval.rawValue
        return index
    }

    internal func convertToDuration(_ width: CGFloat) -> TimeInterval {
        let newDuration = TimeInterval((width / intervalStepInPx) * CGFloat(applyedTimeInterval.rawValue))
        let tr = Int(newDuration.truncatingRemainder(dividingBy: TimeInterval(applyedTimeInterval.rawValue)))
        let roundDuration = Int(newDuration - TimeInterval(tr))
        return TimeInterval(roundDuration)
    }

    internal func convertToIndex(_ xOrigin: CGFloat) -> Int {
        let index = Int((xOrigin - CGFloat(startPointOffset))/intervalStepInPx)
        let maxIndex = getMaxIndex()
        if index > maxIndex { return maxIndex }
        return index
    }

    internal func xOrigin(for index: Int) -> CGFloat {
        return CGFloat(index) * intervalStepInPx
    }

    internal func getMaxIndex() -> Int {
        if let maxIndex = timeSectorsMap.keys.max(by: { $0.intValue < $1.intValue })?.intValue {
            return maxIndex > 0 ? maxIndex - 1 : maxIndex
        }
        return 0
    }

}

