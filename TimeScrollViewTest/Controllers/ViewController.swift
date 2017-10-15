//
//  ViewController.swift
//  TimeScrollViewTest
//
//  Created by Dimitry Panychyk on 10/1/17.
//  Copyright © 2017 d'Man. All rights reserved.
//

import UIKit

class ViewController: UIViewController, CTimeLineViewDelegate, CTimeLineViewDataSource {
    
    @IBOutlet weak var timeIntervalScrollView: UIScrollView!
    @IBOutlet weak var timeIntervalScrollView2: UIScrollView!
    
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

        let timeLineSyncManager = TimeLineViewSyncManager()
        
        let timeLineViewModel = CTimeLineViewModel()
        timeLineViewModel.unavailableTimeIntervalsList = unavailableTimeIntervals
        timeLineViewModel.reservedTimeIntervalsList    = reservations
        timeLineViewModel.selectedTimeInterval         = selectedTimeInterval

        let timeLineView = CTimeLineView(parent: timeIntervalScrollView)
        timeLineView.timeLineViewModel = timeLineViewModel
        timeLineView.dataSource = self
        timeLineView.delegate = self
        timeLineView.syncManager = timeLineSyncManager
        timeIntervalScrollView.contentSize = CGSize(width: timeLineView.timeLineContentSize().width + 40, height: timeLineView.timeLineContentSize().height)
        timeLineView.invalidate()
        
        let timeLineView2 = CTimeLineView(parent: timeIntervalScrollView2)
//        timeLineView2.timeLineViewModel = timeLineViewModel
        timeLineView2.dataSource = self
        timeLineView2.delegate = self
        timeLineView2.syncManager = timeLineSyncManager
        timeIntervalScrollView2.contentSize = CGSize(width: timeLineView2.timeLineContentSize().width + 40, height: timeLineView2.timeLineContentSize().height)
        timeLineView2.invalidate()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - CTimeLineViewDelegate:
    
    func timeLineView(_ timeLineView: CTimeLineView!, onSelectedTimeIntervalChange dateInterval: CDateInterval!) {
        print("newDateInterval startDate = \(dateInterval.startDate) \nendDate = \(dateInterval.endDate)")
    }
    
    // MARK: - CTimeLineViewDataSource:
    
    func timeIntersectWithReservations(for timeLineView: CTimeLineView!) -> Bool {
        return false
    }
    
    func step(for timeLineView: CTimeLineView!) -> CTimeIntervals {
        return .mins15
    }
    
    private let maxIntervalTwoHours = 2*60*60

    func maxAppliableTimeIntervalInSecs(for timeLineView: CTimeLineView!) -> Int {
        return maxIntervalTwoHours
    }
    
    
}

