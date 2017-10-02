//
//  CTimeScrollView.swift
//  TimeScrollViewTest
//
//  Created by Dimitry Panychyk on 9/28/17.
//  Copyright © 2017 d'Man. All rights reserved.
//

import UIKit

@objc enum CTimeIntervals : Int {
    case mins15 = 900  // 15*60
    case mins30 = 1800 // 30*60
    case mins60 = 3600 // 60*60
}

class CTimeScrollView: UIScrollView {
    
    lazy var canvas: CTimeScrollViewCanvas = {
        let tmpCanvas = CTimeScrollViewCanvas(self)
        self.addSubview(tmpCanvas)
        return tmpCanvas
    }()
    
    var hashMap = [NSNumber : CDateInterval]()
    
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
    
    // Design:
    let separatorWidth: CGFloat     = 1.0
    let separatorColor: CGColor     = UIColor.black.cgColor
    let timeLabelColor: UIColor     = .red
    let timeLabelFont: UIFont       = UIFont.systemFont(ofSize: 10)
    let timeLabelCharSpacing: Float = 0.7
    
    @objc var timeIntervals: CTimeIntervals = .mins30 {
        didSet {
            drawTimeIntervals()
        }
    }
    
    @objc var unavailableIntervals: [CDateInterval]? {
        didSet {
            drawTimeIntervals()
        }
    }
    
    var intervalStepInPx: CGFloat {
        get {
            switch self.timeIntervals {
            case .mins15:
                return mins15Step
            case .mins30:
                return mins30Step
            case .mins60:
                return mins60Step
            default:
                preconditionFailure("CTimeScrollView wrong intervalStepInPx")
            }
        }
    }
    
    var tapGesture: UITapGestureRecognizer? = nil
    
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
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        if let tapGesture = tapGesture {
            tapGesture.require(toFail: panGestureRecognizer)
            addGestureRecognizer(tapGesture)
        }
    }
    
    func drawTimeIntervals() {
        contentSize = CGSize(width: (CGFloat(oneDayInSec/timeIntervals.rawValue) * intervalStepInPx) + separatorWidth, height: bounds.size.height)
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        canvas.setNeedsDisplay()
    }
    
    @objc private func tapAction(_ gesture: UITapGestureRecognizer) {
        let points = gesture.location(in: canvas)
        let index = Int(points.x/intervalStepInPx)
        print("startDate = \(hashMap[NSNumber(value: index)]!.startDate)\nendDate = \(hashMap[NSNumber(value: index)]!.endDate)")
    }
    
}

extension CTimeScrollView: CTimeScrollViewCanvasDelegate {
    
    func appliedDateInterval(_ dateInterval: CDateInterval!, forIndex index: NSNumber!) {
        hashMap[index] = dateInterval
    }
    
}
























