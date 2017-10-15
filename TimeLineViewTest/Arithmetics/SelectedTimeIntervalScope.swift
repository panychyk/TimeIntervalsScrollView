//
//  SelectedTimeIntervalScope.swift
//  TimeScrollViewTest
//
//  Created by Dimitry Panychyk on 10/11/17.
//  Copyright © 2017 d'Man. All rights reserved.
//

import Foundation

struct SelectedTimeIntervalScope {
    let minValueX: CGFloat
    let maxValueX: CGFloat
    
    static func zero() -> SelectedTimeIntervalScope {
        return SelectedTimeIntervalScope(minValueX: 0, maxValueX: 0)
    }
    
    func intersect(_ scope: SelectedTimeIntervalScope) -> SelectedTimeIntervalScope {
        let newMin = self.minValueX > scope.minValueX ? self.minValueX : scope.minValueX
        let newMax = self.maxValueX > scope.maxValueX ? scope.maxValueX : self.maxValueX
        return SelectedTimeIntervalScope(minValueX: newMin, maxValueX: newMax)
    }
}
