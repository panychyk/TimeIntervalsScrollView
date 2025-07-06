//
//  TimeLineView.swift
//  TimeScrollViewTest
//
//  Created by Dimitry Panychyk on 10/1/17.
//  Copyright © 2017 d'Man. All rights reserved.
//

import UIKit

public class AvailabilityTimelineView: UIView, TimeSliderThumbViewPanDelegate, AvailabilityReservationViewDelegate {

    var timeLineViewAppearance = AvailabilityTimelineDefaultStyle()

    public weak var delegate: AvailabilityTimelineViewDelegate?
    public weak var dataSource: AvailabilityTimelineViewDataSource? {
        didSet { reloadData() }
    }
    
    public var date: Date!

    private var startPointOffset: Int {
        return Int(round((timeLineViewAppearance.tickWidth)/2))
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

    private(set) var allowIntersectWithSelectedTimeInterval = false

    private(set) var maxAppliableTimeIntervalInSecs = 0

    private(set) var applyedTimeInterval: AvailabilityTimelineInterval = .mins30

    public private(set) var timeLineViewModel: AvailabilityTimelineViewModel?
    
    var reservationViews = [AvailabilityReservationView]()
    
    var intervalStepInPx: CGFloat {
        get {
            switch self.applyedTimeInterval {
                case .mins15:
                    return timeLineViewAppearance.pixelsPer15Min
                case .mins30:
                    return timeLineViewAppearance.pixelsPer30Min
                case .hour:
                    return timeLineViewAppearance.pixelsPer60Min
            }
        }
    }

    var isEnableTapGesture: Bool = true {
        didSet {
            onTimeSectionTapGesture.isEnabled = isEnableTapGesture
        }
    }

    // Subviews:
    lazy var thumbView: TimeSliderThumbView = {
        let thumbView = TimeSliderThumbView(style: timeLineViewAppearance)
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
    var timeSectorsMap   = [NSNumber : DateInterval]()

    lazy var onTimeSectionTapGesture: UITapGestureRecognizer = {
        let onTimeSectionTapGesture = UITapGestureRecognizer(target: self, action: #selector(onTimeSectionTapAction(_:)))
        return onTimeSectionTapGesture
    }()

    internal var availableRangeIntervalForIndexMap = [NSNumber : TimeSlotSelectionRange]()

    // MARK: - Static:
    
    public static func getTimeLineSize(tickInterval: AvailabilityTimelineInterval, appearance: AvailabilityTimelineStyle = AvailabilityTimelineDefaultStyle()) -> CGSize {
        var intervalStepInPx: CGFloat!
        switch tickInterval {
            case .mins15:
                intervalStepInPx = appearance.pixelsPer15Min
            case .mins30:
                intervalStepInPx = appearance.pixelsPer30Min
            case .hour:
                intervalStepInPx = appearance.pixelsPer60Min
        }
        
        let contentSize = CGSize(
            width: (CGFloat(oneDayInSec/tickInterval.rawValue) * intervalStepInPx) + appearance.tickWidth + appearance.thumbSize.width/2,
            height: appearance.timelineHeight
        )
        
        return contentSize
    }
    
    // MARK: - Init:

    public convenience init(parent: UIView) {
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
    public func invalidate() {
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
    }
    
    func invalidateSelectedTimeInterval(minX: CGFloat, maxX: CGFloat, timeInterval: DateInterval) {
        if timeLineViewModel == nil {
            timeLineViewModel = AvailabilityTimelineViewModel()
        }
        timeLineViewModel!.selectedInterval = timeInterval

        hideSelectedTimeIntervalView(false)
        selectedTimeIntervalView.frame = trackViewRect(minX: minX, maxX: maxX)
        thumbView.setCenter(x: maxX, y: selectedTimeIntervalView.frame.midY)

        // calc intersection with other reservations
        let index = indexOfDate(timeInterval.start)
        if let scope = availableRangeIntervalForIndexMap[NSNumber(integerLiteral: index)] {
            let offset = timeLineViewAppearance.tickWidth
            let isIntersectReservations = maxX > (scope.maxValueX + offset)
            applySelectedViewIntersectStyle(isIntersectReservations)
        } else {
            applySelectedViewIntersectStyle(true)
        }
    }

    func timeLineContentSize() -> CGSize {
        let contentSize = CGSize(
            width: (CGFloat(AvailabilityTimelineView.oneDayInSec/applyedTimeInterval.rawValue) * intervalStepInPx) + timeLineViewAppearance.tickWidth + timeLineViewAppearance.thumbSize.width/2,
            height: timeLineViewAppearance.timelineHeight
        )
        return contentSize
    }

    func timeLineSafeAreaRect() -> CGRect {
        let contentSize = CGSize(
            width: (CGFloat(AvailabilityTimelineView.oneDayInSec/applyedTimeInterval.rawValue) * intervalStepInPx) + timeLineViewAppearance.tickWidth,
            height: timeLineViewAppearance.timelineHeight
        )
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
            applyedTimeInterval = dataSource.timeStep(for: self)
            allowIntersectWithSelectedTimeInterval = dataSource.hasConflictWithReservations(in: self)
            maxAppliableTimeIntervalInSecs = dataSource.maximumReservableIntervalInSeconds(for: self)
            timeLineViewModel = dataSource.viewModel(for: self)
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
    
    func convertToWidth(_ timeInterval: DateInterval) -> CGFloat {
        return convertToWidth(timeInterval.duration)
    }
    
    func dateIntervalFor(index: Int) -> DateInterval? {
        return timeSectorsMap[NSNumber(value: index)]
    }
    
    // MARK: - Draw:
    public override func draw(_ rect: CGRect) {
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
        context?.setLineWidth(timeLineViewAppearance.tickWidth)
        for xOrigin in stride(from: startPointOffset, through: Int(rect.width), by: Int(intervalStepInPx)) {
            let index = xOrigin/Int(intervalStepInPx)

            appendDate(forIndex: index)
            if xOrigin == Int(rect.width) &&
                (timeLineViewAppearance.tickWidth.truncatingRemainder(dividingBy: 2.0)) != 0 {
                let newX = CGFloat(xOrigin - Int(round((timeLineViewAppearance.tickWidth)/2)))
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
        var height: CGFloat = timeLineViewAppearance.tickHeightFor60Min
        if index > 0 {
            switch applyedTimeInterval {
            case .mins15:
                if CGFloat(index).truncatingRemainder(dividingBy: 2.0) != 0 {
                    height = timeLineViewAppearance.tickHeightFor15Min
                } else if CGFloat(index/2).truncatingRemainder(dividingBy: 2.0) != 0 {
                    height = timeLineViewAppearance.tickHeightFor30Min
                }
            case .mins30:
                if CGFloat(index).truncatingRemainder(dividingBy: 2.0) != 0 {
                    height = timeLineViewAppearance.tickHeightFor30Min
                }
            case .hour:
                break
            }
        }
        let yOrigin = rect.height - height
        if height == timeLineViewAppearance.tickHeightFor60Min {
            if let dateTime = timeSectorsMap[NSNumber(value: index)] {
                drawTimeText(dateTime.start.shortHoursString(defaultCalendar),
                         at: CGPoint(x: (xOrigin + 6.0), y: yOrigin))
            }
        }

        context?.setStrokeColor(timeLineViewAppearance.tickColor.cgColor)
        context?.move(to: CGPoint(x: xOrigin, y: yOrigin))
        context?.addLine(to: CGPoint(x: xOrigin, y: rect.height))
        context?.strokePath()

    }

    func drawTimeText(_ text: String, at point: CGPoint) {
        let attributedTimeString = text.attributedString(
            font: timeLineViewAppearance.timeLabelStyle.font,
            charSpace: Float(timeLineViewAppearance.timeLabelStyle.charSpace),
            tintColor: timeLineViewAppearance.timeLabelStyle.color
        )
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
            if isContainsInAvailableTimeIntervals(currDateInterval.start) == false {
                disabledIndexMap[currIndex] = true
                //
                let xOrigin = CGFloat(currIndex) * intervalStepInPx
                let r = CGRect(origin: CGPoint(x: CGFloat(xOrigin),
                                               y: rect.height - timeLineViewAppearance.unavailableSlotHeight),
                               size: CGSize(width: intervalStepInPx,
                                            height: timeLineViewAppearance.unavailableSlotHeight))
                timeLineViewAppearance.unavailableSlotImage?.draw(in: r)
                UIColor(red: 241/255, green: 241/255, blue: 241/255, alpha: 0.6).setFill()
                UIRectFillUsingBlendMode(r, .multiply)
            }
        }
    }

    //Reserved:
    func drawReservations(on rect: CGRect) {
        guard
            let reservations = timeLineViewModel?.reservations,
            !reservations.isEmpty else { return }
        
        for reservation in reservations {
            let reservationView = AvailabilityReservationView(reservation, appearance: timeLineViewAppearance)
            // Set sectors as Unavailable
            let fromIndex = indexOfDate(reservation.reservationStartDate)
            let endIndex  = indexOfDate(reservation.reservationEndDate)
            if fromIndex < endIndex {
                for sectorIndex in fromIndex..<endIndex {
                    disabledIndexMap[sectorIndex] = true
                }
            }
            let width = convertToWidth(reservation.reservationEndDate.timeIntervalSince(reservation.reservationStartDate))
            reservationView.frame = CGRect(
                x: self.xOrigin(for: fromIndex),
                y: rect.height - timeLineViewAppearance.reservationHeight,
                width: width - timeLineViewAppearance.tickWidth,
                height: timeLineViewAppearance.reservationHeight
            )
            reservationView.delegate = self
            addSubview(reservationView)
            reservationViews.append(reservationView)
        }
    }

    //SelectedTimeInterval:
    func drawSelectedTimeInterval(on rect: CGRect) {
        guard
            let selectedInterval = timeLineViewModel?.selectedInterval
        else {
                hideSelectedTimeIntervalView(true)
                return
        }
        hideSelectedTimeIntervalView(false)
        let fromSectorIndex = indexOfDate(selectedInterval.start)
        let throughSelectedIndex = indexOfDate(selectedInterval.end)
        var isIntersectReservedSection = false
        for selectedIndex in fromSectorIndex..<throughSelectedIndex {
            if let isDisabled = disabledIndexMap[selectedIndex],
                isDisabled == true {
                isIntersectReservedSection = true
                break
            }
        }
        let xOrigin = CGFloat(Int(CGFloat(fromSectorIndex) * intervalStepInPx))
        let width = convertToWidth(selectedInterval)
        
        selectedTimeIntervalView.frame = trackViewRect(minX: xOrigin, maxX: (xOrigin + width))
        thumbView.setCenter(x: (xOrigin + width), y: selectedTimeIntervalView.frame.midY)
        applySelectedViewIntersectStyle(isIntersectReservedSection)
    }

    func hideSelectedTimeIntervalView(_ hide: Bool) {
        selectedTimeIntervalView.isHidden = hide
        if !isHiddenThumbView { thumbView.isHidden = hide }
        if !hide {
            bringSubviewToFront(selectedTimeIntervalView)
            bringSubviewToFront(thumbView)
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
                        TimeSlotSelectionRange(minValueX: minValueX,
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
        return timeLineViewModel?.availableIntervals?.contains(where: { $0.contains(date) }) ?? false
    }

    // MARK: - HitTest:
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
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
    var allowedSelectionScope: TimeSlotSelectionRange? {
        guard
            let selectedInterval = timeLineViewModel?.selectedInterval,
            !allowIntersectWithSelectedTimeInterval
        else { return nil }
        // need to set scope limit [min value -|- max value]
        let fromSectorIndex = indexOfDate(selectedInterval.start)
        let selectedTimeIntervalScope = availableRangeIntervalForIndexMap[NSNumber(integerLiteral: fromSectorIndex)]
        return selectedTimeIntervalScope
    }

    var timeIntervalScope: TimeSlotSelectionRange {
        let maxTimeIntervalInSecs = maxAppliableTimeIntervalInSecs
        guard let selectedInterval = timeLineViewModel?.selectedInterval else { return .zero() }
        let width = (CGFloat(maxTimeIntervalInSecs/applyedTimeInterval.rawValue) * intervalStepInPx)
        let minValueX = convertToRect(selectedInterval).minX + intervalStepInPx
        let maxValueX = convertToRect(selectedInterval).minX + width
        return TimeSlotSelectionRange(minValueX: minValueX, maxValueX: maxValueX)
    }

    func thumbView(_ thumbView: TimeSliderThumbView, didChangePoint point: CGPoint) -> (Void) {
        guard let selectedInterval = timeLineViewModel?.selectedInterval else { return }
        invalidateSelectedTimeInterval(
            minX: selectedTimeIntervalView.frame.minX,
            maxX: point.x,
            timeInterval: selectedInterval
        )
    }

    func thumbView(_ thumbView: TimeSliderThumbView, didFinishScrollingWithPoint point: CGPoint) -> (Void) {
        let truncRemainder = point.x.truncatingRemainder(dividingBy: intervalStepInPx)
        let subtraction = intervalStepInPx - truncRemainder
        // round to greater
        var newPointX = point.x + subtraction
        if subtraction >= intervalStepInPx/2 {
            // round to lesser
            newPointX = point.x - truncRemainder
        }
        let newEndPoint = CGPoint(x: newPointX, y: point.y)
        let newSize = CGSize(
            width: newEndPoint.x - selectedTimeIntervalView.frame.origin.x,
            height: selectedTimeIntervalView.frame.height
        )
        let newRect = CGRect(origin: selectedTimeIntervalView.frame.origin, size: newSize)
        let newTimeInterval = convertToTimeInterval(newRect)
        invalidateSelectedTimeInterval(
            minX: selectedTimeIntervalView.frame.minX,
            maxX: newPointX,
            timeInterval: newTimeInterval
        )
        delegate?.availabilityTimelineView(self, didSelectTimeInterval: newTimeInterval)
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
                let newDuration = calcNewDuration(
                    in: scope,
                    for: index,
                    with: timeLineViewModel?.selectedInterval?.duration
                )
                let minX = xOrigin(for: index)
                let maxX = minX + convertToWidth(newDuration)
                let newTimeInterval = DateInterval(start: sectorTimeInterval.start, duration: newDuration)
                
                if timeLineViewModel?.selectedInterval != nil {
                    delegate?.availabilityTimelineView(self, didUpdateSelectedTimeInterval: newTimeInterval)
                } else {
                    delegate?.availabilityTimelineView(self, didSelectTimeInterval: newTimeInterval)
                }
                
                invalidateSelectedTimeInterval(minX: minX, maxX: maxX, timeInterval: newTimeInterval)
            }
        }
    }
    
    // MARK: - ReservationViewDelegate
    
    public func reservation(view: AvailabilityReservationView, didTap reservation: Reservation) {
        delegate?.availabilityTimelineView(self, didSelectReservation: reservation, sender: view)
    }

    // MARK: - Private:
    internal func appendDate(forIndex index: Int) {
        let startDateTime = date.dateByAppendingSecs(applyedTimeInterval.rawValue * index, calendar: defaultCalendar)
        let newDateInterval = DateInterval(start: startDateTime, duration: TimeInterval(applyedTimeInterval.rawValue))
        timeSectorsMap[NSNumber(value: index)] = newDateInterval
    }
    
    internal func applySelectedViewIntersectStyle(_ isIntersect: Bool) {
        thumbView.setIntersectState(isIntersect)
        selectedTimeIntervalView.updateConflictState(isIntersect)
    }

    //returns the rect for the track view between the lower and upper values based on SelectedTimeIntervalView object
    internal func trackViewRect(minX: CGFloat, maxX: CGFloat) -> CGRect {
        let rect = CGRect(
            x: minX,
            y: self.frame.height - selectedTimeIntervalView.timeLineViewAppearance.selectionHeight,
            width: maxX - minX,
            height: selectedTimeIntervalView.timeLineViewAppearance.selectionHeight
        )
        return rect
    }

    internal func calcNewDuration(in newRange: TimeSlotSelectionRange, for index: Int, with oldDuration: TimeInterval?) -> TimeInterval {
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

    internal func convertToTimeInterval(_ rect: CGRect) -> DateInterval {
        let startIndex = Int(rect.minX / intervalStepInPx)
        var endIndex = Int(rect.maxX / intervalStepInPx)
        if endIndex > 0 {
            endIndex -= 1
        }
        let dateInterval = DateInterval(
            start: timeSectorsMap[NSNumber(value: startIndex)]!.start,
            end: timeSectorsMap[NSNumber(value: endIndex)]!.end
        )
        return dateInterval
    }

    internal func convertToRect(_ timeInterval: DateInterval) -> CGRect {
        let xOrigin = CGFloat(indexOfDate(timeInterval.start)) * intervalStepInPx
        let width = convertToWidth(timeInterval) - timeLineViewAppearance.tickWidth
        let rect = CGRect(x: xOrigin, y: 0, width: width, height: 50)
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
        guard let maxIndex = timeSectorsMap.keys.max(by: { $0.intValue < $1.intValue })?.intValue
        else { return 0 }
        return maxIndex > 0 ? maxIndex - 1 : maxIndex
    }

}

