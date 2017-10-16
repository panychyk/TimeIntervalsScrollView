//
//  TimeLineViewAppearance.swift
//  TimeLineViewTest
//
//  Created by Dimitry Panychyk on 10/16/17.
//  Copyright © 2017 d'Man. All rights reserved.
//

import Foundation
import UIKit

protocol TimeLineViewAppearance {
    
    typealias TimeLabelAttributes = (color: UIColor, font: UIFont, charSpace: CGFloat)
    
    var timeLineViewHeight: CGFloat { get }
    var tickMark15minsHeight: CGFloat { get }
    var tickMark30minsHeight: CGFloat { get }
    var tickMark60minsHeight: CGFloat { get }
    var mins15StepPx: CGFloat { get }
    var mins30StepPx: CGFloat { get }
    var mins60StepPx: CGFloat { get }
    var timeLabelAttributes: TimeLabelAttributes { get }
    var timeLabelOffset: CGPoint { get }
    var timeLineViewbackgroundColor: UIColor { get }
    var tickMarkColor: UIColor { get }
    var tickMarkWidth: CGFloat { get }
    var unavailableZoneImage: UIImage? { get }
    var unavailableZoneImageBackgroundColor: UIColor { get }
    var unavailableZoneHeight: CGFloat { get }
    var reservationsViewBorderColor: UIColor { get }
    var reservationsViewBackgroundColor: UIColor { get }
    var reservationsViewBorderWidth: CGFloat { get }
    var reservationsViewUserImageSize: CGSize { get }
    var reservationsViewHeight: CGFloat { get }
    var selectedTimeViewBorderColor: UIColor { get }
    var selectedTimeViewBackgroundColor: UIColor { get }
    var selectedTimeViewBorderConflictColor: UIColor { get }
    var selectedTimeViewBackgroundConflictColor: UIColor { get }
    var selectedTimeViewBorderWidth: CGFloat { get }
    var selectedTimeViewHeight: CGFloat { get }
    var thumbBorderColor: UIColor { get }
    var thumbBackgroundColor: UIColor { get }
    var thumbBorderConflictColor: UIColor { get }
    var thumbBackgroundConflictColor: UIColor { get }
    var thumbBorderWidth: CGFloat { get }
    var thumbSize: CGSize { get }
    var thumbCornerRadius: CGFloat { get }
    
}

extension TimeLineViewAppearance {
    
    var timeLineViewHeight: CGFloat { return 70.0 }
    var tickMark15minsHeight: CGFloat { return 25.0 }
    var tickMark30minsHeight: CGFloat { return 40.0 }
    var tickMark60minsHeight: CGFloat { return 70.0 }
    var mins15StepPx: CGFloat { return 28.0 }
    var mins30StepPx: CGFloat { return 42.0 }
    var mins60StepPx: CGFloat { return 82.0 }
    var timeLabelAttributes: TimeLabelAttributes {
        return (UIColor.red, UIFont.systemFont(ofSize: 10), 0.7)
    }
    var timeLabelOffset: CGPoint {
        return CGPoint(x: 6, y: 0)
    }
    var timeLineViewbackgroundColor: UIColor { return .white }
    var tickMarkColor: UIColor {
        return UIColor(red: 233/255, green: 233/255, blue: 233/255, alpha: 1)
    }
    var tickMarkWidth: CGFloat { return 1.0 }
    var unavailableZoneImage: UIImage? { return UIImage() }
    var unavailableZoneImageBackgroundColor: UIColor {
        return UIColor(red: 241/255, green: 241/255, blue: 241/255, alpha: 0.6)
    }
    var unavailableZoneHeight: CGFloat { return 50.0 }
    var reservationsViewBorderColor: UIColor {
        return UIColor(red: 28.0/255.0, green: 66.0/255.0, blue: 52.0/255.0, alpha: 1.0)
    }
    var reservationsViewBackgroundColor: UIColor {
        return UIColor(red: 169.0/255.0, green: 184.0/255.0, blue: 178.0/255.0, alpha: 1.0)
    }
    var reservationsViewBorderWidth: CGFloat { return 1.0 }
    var reservationsViewUserImageSize: CGSize { return CGSize(width: 24, height: 24) }
    var reservationsViewHeight: CGFloat { return 50.0 }
    var selectedTimeViewBorderColor: UIColor {
        return UIColor(red: 28.0/255.0, green: 66.0/255.0, blue: 52.0/255.0, alpha: 1.0)
    }
    var selectedTimeViewBackgroundColor: UIColor {
        return UIColor(red: 28.0/255.0, green: 66.0/255.0, blue: 52.0/255.0, alpha: 0.8)
    }
    var selectedTimeViewBorderConflictColor: UIColor {
        return UIColor(red: 208.0/255.0, green: 1.0/255.0, blue: 27.0/255.0, alpha: 1.0)
    }
    var selectedTimeViewBackgroundConflictColor: UIColor {
        return UIColor(red: 208.0/255.0, green: 1.0/255.0, blue: 27.0/255.0, alpha: 0.3)
    }
    var selectedTimeViewBorderWidth: CGFloat { return 1.5 }
    var selectedTimeViewHeight: CGFloat { return 50.0 }
    var thumbBorderColor: UIColor {
        return UIColor(red: 28.0/255.0, green: 66.0/255.0, blue: 52.0/255.0, alpha: 1.0)
    }
    var thumbBackgroundColor: UIColor { return .white }
    var thumbBorderConflictColor: UIColor {
        return UIColor(red: 208.0/255.0, green: 1.0/255.0, blue: 27.0/255.0, alpha: 1.0)
    }
    var thumbBackgroundConflictColor: UIColor { return .white }
    var thumbBorderWidth: CGFloat { return 2.0 }
    var thumbSize: CGSize { return CGSize(width: 12.0, height: 24.0) }
    var thumbCornerRadius: CGFloat { return 100.0 }
    
}



