//
//  ReservationModel.swift
//  TimeScrollViewTest
//
//  Created by Dimitry Panychyk on 10/8/17.
//  Copyright © 2017 d'Man. All rights reserved.
//

import Foundation
import UIKit
import AvailabilityTimeline

class ReservationModel: Reservation {

    let reservationId: Int
    let hostName: String
    let hostImageName: String
    let reservationTimeInterval: DateInterval
    
    var reservationImageURL: URL? { nil }
    
    var reservationImage: UIImage? {
        UIImage(named: hostImageName)
    }
    
    var reservationStartDate: Date {
        reservationTimeInterval.start
    }
    
    var reservationEndDate: Date {
        reservationTimeInterval.end
    }
    
    init(
        reservationId: Int,
        reservationTimeInterval: DateInterval,
        hostName: String,
        hostImageName: String = "host_image"
    ) {
        self.reservationId = reservationId
        self.reservationTimeInterval = reservationTimeInterval
        self.hostName = hostName
        self.hostImageName = hostImageName
    }
}
