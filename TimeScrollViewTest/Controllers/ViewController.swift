//
//  ViewController.swift
//  TimeScrollViewTest
//
//  Created by Dimitry Panychyk on 10/1/17.
//  Copyright © 2017 d'Man. All rights reserved.
//

import UIKit

class ViewController: UIViewController, CTimeIntervalScrollViewDelegate, CTimeIntervalScrollViewDataSource {
    
    @IBOutlet weak var timeIntervalScrollView: CTimeIntervalScrollView!
    @IBOutlet weak var timeIntervalScrollView2: CTimeIntervalScrollView!
    
    
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
            ReservationModel(CDateInterval(start: date.apply(hours: 12, minutes: 0, calendar: calendar), duration: 15*60), hostName: "Second Best Friend"),
            ReservationModel(CDateInterval(start: date.apply(hours: 18, minutes: 0, calendar: calendar), duration: 15*60), hostName: "Second Best Friend")
        ]
        
        let selectedTimeInterval = CDateInterval(start: date.apply(hours: 6, minutes: 30, calendar: calendar), duration: 45*60)
        
        let syncManager = TimeScrollViewSyncManager.shared
        
        let timeIntervalScrollViewModel = CTimeIntervalScrollViewModel()
        timeIntervalScrollViewModel.unavailableTimeIntervalsList = unavailableTimeIntervals
        timeIntervalScrollViewModel.reservedTimeIntervalsList    = reservations
        timeIntervalScrollViewModel.selectedTimeInterval         = selectedTimeInterval
        
        timeIntervalScrollView.timeIntervalScrollViewDelegate = self
        timeIntervalScrollView.registerToChangeSelectedTimeIntervalsSimultaneouslyWithOtherViews = true
        timeIntervalScrollView.timeIntervalScrollViewModel = timeIntervalScrollViewModel
        timeIntervalScrollView.timeIntervalScrollViewDataSource = self
        syncManager.listeners.append(timeIntervalScrollView.syncListener)

        timeIntervalScrollView2.isAllowThumbView = false
        timeIntervalScrollView2.timeIntervalScrollViewModel = timeIntervalScrollViewModel
        timeIntervalScrollView2.registerToChangeSelectedTimeIntervalsSimultaneouslyWithOtherViews = true
        timeIntervalScrollView2.timeIntervalScrollViewDataSource = self
        syncManager.listeners.append(timeIntervalScrollView2.syncListener)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - CTimeIntervalScrollViewDelegate:
    
    func timeIntervalScrollView(_ scrollView: CTimeIntervalScrollView!, onSelectedTimeIntervalChange dateInterval: CDateInterval!) {
        print("newDateInterval startDate = \(dateInterval.startDate) \nendDate = \(dateInterval.endDate)")
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

