//
//  CTimeIntervalScrollView.swift
//  TimeScrollViewTest
//
//  Created by Dimitry Panychyk on 9/28/17.
//  Copyright © 2017 d'Man. All rights reserved.
//

import UIKit

class CTimeIntervalScrollView: UIScrollView {
    
    weak var timeIntervalScrollViewDelegate: CTimeIntervalScrollViewDelegate?
    weak var timeIntervalScrollViewDataSource: CTimeIntervalScrollViewDataSource? {
        didSet {
            reloadData()
        }
    }

    lazy var canvas: CTimeIntervalDrawableView = {
        let tmpCanvas = CTimeIntervalDrawableView(self)
        self.addSubview(tmpCanvas)
        return tmpCanvas
    }()
    
    var timeSectorsMap = [NSNumber : CDateInterval]()
    
    var timeIntervalScrollViewModel = CTimeIntervalScrollViewModel() {
        didSet {
            drawTimeIntervals()
        }
    }
    public var isAllowThumbView = true
    private(set) var allowIntersectWithSelectedTimeInterval = false
    private(set) var maxAppliableTimeIntervalInSecs = 0
    
    let oneDayInSec = 86400 // 24*60*60
    lazy var calendar: Calendar = {
        var cal = Calendar.current
        cal.timeZone = TimeZone(secondsFromGMT: 0)!
        return cal
    }()
    
    // Parameters:
    let mins15Step: CGFloat = 28.0
    let mins30Step: CGFloat = 42.0
    let mins60Step: CGFloat = 82.0
    
    let mins15SeparatorHeight: CGFloat = 25.0
    let mins30SeparatorHeight: CGFloat = 40.0
    let mins60SeparatorHeight: CGFloat = 70.0
    
    let unavailableSectorImageHeight: CGFloat = 50.0
    
    // Design:
    let separatorWidth: CGFloat     = 1.0
    let separatorColor: CGColor     = UIColor(red: 233/255, green: 233/255, blue: 233/255, alpha: 1).cgColor
    let timeLabelColor: UIColor     = .red
    let timeLabelFont: UIFont       = UIFont.systemFont(ofSize: 10)
    let timeLabelCharSpacing: Float = 0.7
    
    let unavailableSectorImage = UIImage(named: "reserved_image")
    
    @objc private(set) var applyedTimeInterval: CTimeIntervals = .mins30
    
    var intervalStepInPx: CGFloat {
        get {
            switch self.applyedTimeInterval {
            case .mins15:
                return mins15Step
            case .mins30:
                return mins30Step
            case .mins60:
                return mins60Step
            default:
                preconditionFailure("CTimeIntervalScrollView wrong intervalStepInPx")
            }
        }
    }
    
    var onTimeSectionTapGesture: UITapGestureRecognizer? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureUI()
    }
    
    func configureUI() {
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator   = false
        onTimeSectionTapGesture = UITapGestureRecognizer(target: self, action: #selector(onTimeSectionTapAction(_:)))
        if let onTimeSectionTapGesture = onTimeSectionTapGesture {
            onTimeSectionTapGesture.require(toFail: panGestureRecognizer)
            addGestureRecognizer(onTimeSectionTapGesture)
        }
    }
    
    override func draw(_ rect: CGRect) {
        canvas.setNeedsDisplay()
    }
    
    @objc private func onTimeSectionTapAction(_ gesture: UITapGestureRecognizer) {
        let points = gesture.location(in: canvas)
        let index = Int(points.x/intervalStepInPx)
        
        print("startDate = \(timeSectorsMap[NSNumber(value: index)]!.startDate)\nendDate = \(timeSectorsMap[NSNumber(value: index)]!.endDate)")
    }
    
    func reloadData() {
        if let timeIntervalScrollViewDataSource = timeIntervalScrollViewDataSource {
            applyedTimeInterval = timeIntervalScrollViewDataSource.stepForTimeIntervalScrollView()
            allowIntersectWithSelectedTimeInterval = timeIntervalScrollViewDataSource.timeIntervalScrollViewAllowIntersectWithReservations()
            maxAppliableTimeIntervalInSecs = timeIntervalScrollViewDataSource.maxAppliableTimeIntervalInSecs()
        }
        drawTimeIntervals()
    }
    
    func drawTimeIntervals() {
        contentSize = CGSize(width: (CGFloat(oneDayInSec/applyedTimeInterval.rawValue) * intervalStepInPx) + separatorWidth, height: bounds.size.height)
        setNeedsDisplay()
    }
    
}

extension CTimeIntervalScrollView: CTimeIntervalDrawableViewDelegate {

    func onApply(_ dateInterval: CDateInterval!, forIndex index: NSNumber!) {
        timeSectorsMap[index] = dateInterval
    }

}
























