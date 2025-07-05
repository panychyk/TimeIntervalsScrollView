//
//  CTimeLineViewModel.swift
//  TimeScrollViewTest
//
//  Created by Dimitry Panychyk on 10/8/17.
//  Copyright © 2017 d'Man. All rights reserved.
//

import Foundation

public class AvailabilityTimelineViewModel {
    
    public var selectedInterval: DateInterval?
    
    public var reservations: [Reservation]? {
        didSet { reservations?.sort { $0.reservationStartDate < $1.reservationStartDate } }
    }
    
    public var availableIntervals: [DateInterval]? {
        didSet { availableIntervals?.sort { $0.start < $1.start } }
    }
    
    public init() {
        
    }
}
