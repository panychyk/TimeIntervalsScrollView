//
//  ViewController.swift
//  TimeScrollViewTest
//
//  Created by Dimitry Panychyk on 10/1/17.
//  Copyright © 2017 d'Man. All rights reserved.
//

import UIKit

class ViewController: UIViewController, CTimeIntervalScrollViewDelegate, CTimeIntervalScrollViewDataSource {

    weak var timeIntervalScrollView: CTimeIntervalScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let date = Date()
        let unavailableTimeIntervals: [CDateInterval] = [
            CDateInterval(start: date.apply(hours: 0, minutes: 0, calendar: calendar), duration: 3*60*60),
            CDateInterval(start: date.apply(hours: 7, minutes: 0, calendar: calendar), duration: 60*60)
        ]
        
        let reservations: [ReservationModel] = [
            ReservationModel(CDateInterval(start: date.apply(hours: 8, minutes: 0, calendar: calendar), duration: 2*60*60), hostName: "Best Friend"),
            ReservationModel(CDateInterval(start: date.apply(hours: 18, minutes: 0, calendar: calendar), duration: 15*60), hostName: "Second Best Friend")
        ]
        
        let selectedTimeInterval = CDateInterval(start: date.apply(hours: 10, minutes: 15, calendar: calendar), duration: 45*60)
        
        let timeIntervalScrollViewModel = CTimeIntervalScrollViewModel()
        timeIntervalScrollViewModel.unavailableTimeIntervalsList = unavailableTimeIntervals
        timeIntervalScrollViewModel.reservadTimeIntervalsList    = reservations
        timeIntervalScrollViewModel.selectedTimeInterval         = selectedTimeInterval
        
        timeIntervalScrollView = self.view as! CTimeIntervalScrollView
        timeIntervalScrollView.timeIntervalScrollViewDelegate = self
        timeIntervalScrollView.timeIntervalScrollViewDataSource = self
        timeIntervalScrollView.timeIntervalScrollViewModel = timeIntervalScrollViewModel
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    // MARK: - CTimeIntervalScrollViewDelegate:
    
    func onSelectedTimeIntervalChange(_ dateInterval: CDateInterval!) {
        print("onSelectedTimeIntervalChange(_:) dateInterval = \(dateInterval)")
    }
    
    func onThumbViewChangeSelectedIntervalRect(_ newRect: CGRect) {
        print("onThumbViewChangeSelectedIntervalRect(_:) newRect = \(newRect)")
    }
    
    // MARK: - CTimeIntervalScrollViewDataSource:
    
    func timeIntervalScrollViewAllowIntersectWithReservations() -> Bool {
        return true
    }
    
    func stepForTimeIntervalScrollView() -> CTimeIntervals {
        return .mins15
    }
    
    private let maxIntervalTwoHours = 2*60*60
    
    func maxAppliableTimeIntervalInSecs() -> Int {
        return maxIntervalTwoHours
    }
    
}

