//
//  ViewController.swift
//  TimeScrollViewTest
//
//  Created by Dimitry Panychyk on 10/1/17.
//  Copyright © 2017 d'Man. All rights reserved.
//

import UIKit

class ViewController: UIViewController, TimeLineViewDelegate, TimeLineViewDataSource {
    
    @IBOutlet weak var timeIntervalScrollView: TimeLineScrollView!
    @IBOutlet weak var timeIntervalScrollView2: TimeLineScrollView!
    
    let timeLineViewModel = CTimeLineViewModel()
    let timeLineSyncManager = TimeLineViewSyncManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let date = Date(timeInterval: TimeInterval(TimeZone.current.secondsFromGMT()), since: Date())
        let availableTimeIntervals: [CDateInterval] = [
            CDateInterval(start: date.apply(hours: 0, minutes: 0, calendar: calendar), duration: 3*60*60),
            CDateInterval(start: date.apply(hours: 7, minutes: 0, calendar: calendar), duration: 60*60),
        ]

        let reservations: [ReservationModel] = [
            ReservationModel(CDateInterval(start: date.apply(hours: 8, minutes: 0, calendar: calendar), duration: 2*60*60), hostName: "Best Friend"),
            ReservationModel(CDateInterval(start: date.apply(hours: 12, minutes: 30, calendar: calendar), duration: 15*60), hostName: "Second Best Friend"),
            ReservationModel(CDateInterval(start: date.apply(hours: 13, minutes: 00, calendar: calendar), duration: 60*60), hostName: "Second Best1 Friend"),
            ReservationModel(CDateInterval(start: date.apply(hours: 14, minutes: 00, calendar: calendar), duration: 30*60), hostName: "Second Best1 Friend"),
            ReservationModel(CDateInterval(start: date.apply(hours: 19, minutes: 30, calendar: calendar), duration: 30*60), hostName: "Second Best1 Friend"),
            ReservationModel(CDateInterval(start: date.apply(hours: 23, minutes: 30, calendar: calendar), duration: 30*60), hostName: "Second Best1 Friend")
        ]

        let selectedTimeInterval = CDateInterval(start: date.apply(hours: 6, minutes: 30, calendar: calendar), duration: 45*60)
        
        timeLineViewModel.availableTimeIntervalsList   = availableTimeIntervals
        timeLineViewModel.reservedTimeIntervalsList    = reservations
        timeLineViewModel.selectedTimeInterval         = selectedTimeInterval
        
        let timeLineView = TimeLineView(parent: timeIntervalScrollView)
        timeIntervalScrollView.timeLineView = timeLineView
        timeLineView.dataSource = self
        timeLineView.delegate = self
        timeLineView.date = Date().dateWithZeroHourAndMinute(calendar)!
        timeLineView.syncManager = timeLineSyncManager
        timeIntervalScrollView.applyContentSize()
        timeLineView.invalidate()
        
        let timeLineView2 = TimeLineView(parent: timeIntervalScrollView2)
        timeIntervalScrollView2.timeLineView = timeLineView2
        timeLineView2.dataSource = self
        timeLineView2.delegate = self
        timeLineView2.date = Date().dateWithZeroHourAndMinute(calendar)!
        timeLineView2.syncManager = timeLineSyncManager
        timeIntervalScrollView2.applyContentSize()
        timeLineView2.invalidate()
        timeIntervalScrollView2.scroll(date: date.apply(hours: 1, minutes: 00, calendar: calendar), position: .center, animate: false)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - TimeLineViewDelegate:
    
    func timeLineView(_ timeLineView: TimeLineView!, didSelectTime dateInterval: CDateInterval!) {
        print("newDateInterval startDate = \(dateInterval.startDate) \nendDate = \(dateInterval.endDate)")
    }
    
    func timeLineView(_ timeLineView: TimeLineView!, onSelectedTimeIntervalChange dateInterval: CDateInterval!) {
        print("newDateInterval startDate = \(dateInterval.startDate) \nendDate = \(dateInterval.endDate)")
    }
    
    // MARK: - TimeLineViewDataSource:
    
    func timeIntersectWithReservations(for timeLineView: TimeLineView) -> Bool {
        return false
    }
    
    func step(for timeLineView: TimeLineView) -> CTimeIntervals {
        return .mins15
    }
    
    private let maxIntervalTwoHours = 2*60*60

    func maxAppliableTimeIntervalInSecs(for timeLineView: TimeLineView) -> Int {
        return maxIntervalTwoHours
    }
    
    func timeLineViewModelFroView(_ timeLineView: TimeLineView) -> CTimeLineViewModel {
        return timeLineViewModel
    }
    
}

