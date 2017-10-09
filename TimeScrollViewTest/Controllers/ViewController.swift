//
//  ViewController.swift
//  TimeScrollViewTest
//
//  Created by Dimitry Panychyk on 10/1/17.
//  Copyright © 2017 d'Man. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    weak var scrollView: CTimeIntervalScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let date = Date()
        let unavailableTimeIntervals: [CDateInterval] = [
            CDateInterval(start: date.apply(hours: 0, minutes: 0, calendar: calendar), duration: 3*60*60),
            CDateInterval(start: date.apply(hours: 6, minutes: 0, calendar: calendar), duration: 60*60)
        ]
        
        let reservations: [ReservationModel] = [
            ReservationModel(CDateInterval(start: date.apply(hours: 8, minutes: 0, calendar: calendar), duration: 2*60*60), hostName: "Best Friend"),
            ReservationModel(CDateInterval(start: date.apply(hours: 18, minutes: 0, calendar: calendar), duration: 15*60), hostName: "Second Best Friend")
        ]
        
        let timeIntervalScrollViewModel = CTimeIntervalScrollViewModel()
        timeIntervalScrollViewModel.unavailableTimeIntervalsList = unavailableTimeIntervals
        timeIntervalScrollViewModel.reservadTimeIntervalsList    = reservations
        
        scrollView = self.view as! CTimeIntervalScrollView
        scrollView.applyedTimeInterval = .mins15
        scrollView.timeIntervalScrollViewModel = timeIntervalScrollViewModel
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

