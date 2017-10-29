//
//  CTimeLineViewModel.swift
//  TimeScrollViewTest
//
//  Created by Dimitry Panychyk on 10/8/17.
//  Copyright © 2017 d'Man. All rights reserved.
//

import Foundation

class CTimeLineViewModel: NSObject {
    
    var selectedTimeInterval: CDateInterval?
    
    var reservedTimeIntervalsList = [TimeLineReservation]() {
        didSet {
            reservedTimeIntervalsList.sort { $0.startDate < $1.startDate }
        }
    }
    
    var availableTimeIntervalsList = [CDateInterval]() {
        didSet {
            availableTimeIntervalsList.sort { $0.startDate < $1.startDate }
        }
    }
    
}
