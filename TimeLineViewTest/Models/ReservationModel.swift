//
//  ReservationModel.swift
//  TimeScrollViewTest
//
//  Created by Dimitry Panychyk on 10/8/17.
//  Copyright © 2017 d'Man. All rights reserved.
//

import Foundation

class ReservationModel: NSObject, TimeLineReservation {
    
    var imagePath: String? {
        return hostImageName
    }
    
    var image: UIImage? {
        return nil
    }
    
    var startDate: Date {
        return reservationTimeInterval.startDate
    }
    
    var endDate: Date {
        return reservationTimeInterval.endDate
    }

    var reservationId            = NSNumber(integerLiteral: 1)
    var reservationTimeInterval  = CDateInterval(start: Date(), duration: 30*60*60)
    var hostName                 = "Unowned"
    let hostImageName            = "host_image"
    
    init(_ reservationTimeInterval: CDateInterval, hostName: String) {
        super.init()
        self.reservationTimeInterval = reservationTimeInterval
        self.hostName = hostName
    }
    
}

