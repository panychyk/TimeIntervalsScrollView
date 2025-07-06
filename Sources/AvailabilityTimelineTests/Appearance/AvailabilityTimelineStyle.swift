//
//  TimeLineViewAppearance.swift
//  TimeLineViewTest
//
//  Created by Dimitry Panychyk on 10/16/17.
//  Copyright © 2017 d'Man. All rights reserved.
//

import Foundation
import UIKit

public protocol AvailabilityTimelineStyle {
    
    typealias TimeLabelStyle = (color: UIColor, font: UIFont, charSpace: CGFloat)
    
    var timelineHeight: CGFloat { get }
    var tickHeightFor15Min: CGFloat { get }
    var tickHeightFor30Min: CGFloat { get }
    var tickHeightFor60Min: CGFloat { get }
    
    var pixelsPer15Min: CGFloat { get }
    var pixelsPer30Min: CGFloat { get }
    var pixelsPer60Min: CGFloat { get }
    
    var timeLabelStyle: TimeLabelStyle { get }
    var timeLabelOffset: CGPoint { get }
    
    var timelineBackgroundColor: UIColor { get }
    var tickColor: UIColor { get }
    var tickWidth: CGFloat { get }
    
    var unavailableSlotImage: UIImage? { get }
    var unavailableSlotBackgroundColor: UIColor { get }
    var unavailableSlotHeight: CGFloat { get }
    
    var reservationBorderColor: UIColor { get }
    var reservationBackgroundColor: UIColor { get }
    var reservationBorderWidth: CGFloat { get }
    var reservationUserImageSize: CGSize { get }
    var reservationHeight: CGFloat { get }
    
    var selectionBorderColor: UIColor { get }
    var selectionBackgroundColor: UIColor { get }
    var selectionConflictBorderColor: UIColor { get }
    var selectionConflictBackgroundColor: UIColor { get }
    var selectionBorderWidth: CGFloat { get }
    var selectionHeight: CGFloat { get }
    
    var thumbBorderColor: UIColor { get }
    var thumbBackgroundColor: UIColor { get }
    var thumbConflictBorderColor: UIColor { get }
    var thumbConflictBackgroundColor: UIColor { get }
    var thumbBorderWidth: CGFloat { get }
    var thumbSize: CGSize { get }
    var thumbCornerRadius: CGFloat { get }
    
}

public extension AvailabilityTimelineStyle {
    
    var timelineHeight: CGFloat { 70.0 }
    var tickHeightFor15Min: CGFloat { 25.0 }
    var tickHeightFor30Min: CGFloat { 40.0 }
    var tickHeightFor60Min: CGFloat { 70.0 }
    var pixelsPer15Min: CGFloat { 28.0 }
    var pixelsPer30Min: CGFloat { 42.0 }
    var pixelsPer60Min: CGFloat { 82.0 }
    var timeLabelStyle: TimeLabelStyle {
        (UIColor.red, UIFont.systemFont(ofSize: 10), 0.7)
    }
    var timeLabelOffset: CGPoint {
        CGPoint(x: 6, y: 0)
    }
    var timelineBackgroundColor: UIColor { .white }
    var tickColor: UIColor {
        UIColor(red: 233/255, green: 233/255, blue: 233/255, alpha: 1)
    }
    var tickWidth: CGFloat { 1.0 }
    var unavailableSlotImage: UIImage? { nil }
    var unavailableSlotBackgroundColor: UIColor {
        UIColor(red: 241/255, green: 241/255, blue: 241/255, alpha: 0.6)
    }
    var unavailableSlotHeight: CGFloat { 50.0 }
    var reservationBorderColor: UIColor {
        UIColor(red: 28.0/255.0, green: 66.0/255.0, blue: 52.0/255.0, alpha: 1.0)
    }
    var reservationBackgroundColor: UIColor {
        UIColor(red: 169.0/255.0, green: 184.0/255.0, blue: 178.0/255.0, alpha: 1.0)
    }
    var reservationBorderWidth: CGFloat { 1.0 }
    var reservationUserImageSize: CGSize { CGSize(width: 24, height: 24) }
    var reservationHeight: CGFloat { 50.0 }
    var selectionBorderColor: UIColor {
        UIColor(red: 28.0/255.0, green: 66.0/255.0, blue: 52.0/255.0, alpha: 1.0)
    }
    var selectionBackgroundColor: UIColor {
        UIColor(red: 28.0/255.0, green: 66.0/255.0, blue: 52.0/255.0, alpha: 0.8)
    }
    var selectionConflictBorderColor: UIColor {
        UIColor(red: 208.0/255.0, green: 1.0/255.0, blue: 27.0/255.0, alpha: 1.0)
    }
    var selectionConflictBackgroundColor: UIColor {
        UIColor(red: 208.0/255.0, green: 1.0/255.0, blue: 27.0/255.0, alpha: 0.3)
    }
    var selectionBorderWidth: CGFloat { 1.5 }
    var selectionHeight: CGFloat { 50.0 }
    var thumbBorderColor: UIColor {
        UIColor(red: 28.0/255.0, green: 66.0/255.0, blue: 52.0/255.0, alpha: 1.0)
    }
    var thumbBackgroundColor: UIColor { .white }
    var thumbConflictBorderColor: UIColor {
        UIColor(red: 208.0/255.0, green: 1.0/255.0, blue: 27.0/255.0, alpha: 1.0)
    }
    var thumbConflictBackgroundColor: UIColor { .white }
    var thumbBorderWidth: CGFloat { 2.0 }
    var thumbSize: CGSize { CGSize(width: 12.0, height: 24.0) }
    var thumbCornerRadius: CGFloat { 100.0 }
}
