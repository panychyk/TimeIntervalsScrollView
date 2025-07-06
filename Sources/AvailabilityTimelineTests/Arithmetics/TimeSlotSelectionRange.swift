//
//  SelectedTimeIntervalScope.swift
//  TimeScrollViewTest
//
//  Created by Dimitry Panychyk on 10/11/17.
//  Copyright © 2017 d'Man. All rights reserved.
//

import Foundation

struct TimeSlotSelectionRange {
    let minValueX: CGFloat
    let maxValueX: CGFloat
    
    static func zero() -> TimeSlotSelectionRange {
        return TimeSlotSelectionRange(minValueX: 0, maxValueX: 0)
    }
    
    func intersect(_ scope: TimeSlotSelectionRange) -> TimeSlotSelectionRange {
        let newMin = self.minValueX > scope.minValueX ? self.minValueX : scope.minValueX
        let newMax = self.maxValueX > scope.maxValueX ? scope.maxValueX : self.maxValueX
        return TimeSlotSelectionRange(minValueX: newMin, maxValueX: newMax)
    }
}
