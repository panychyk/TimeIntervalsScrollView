//
//  Arithmetics.swift
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
}
