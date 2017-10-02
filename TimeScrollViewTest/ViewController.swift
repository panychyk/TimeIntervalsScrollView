//
//  ViewController.swift
//  TimeScrollViewTest
//
//  Created by Dimitry Panychyk on 10/1/17.
//  Copyright © 2017 d'Man. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    weak var scrollView: CTimeScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let date = Date()
        let unavailableTimeIntervals: [CDateInterval] = [CDateInterval(start: date.apply(hours: 0, minutes: 0, calendar: calendar), duration: 3*60*60),
                                                         CDateInterval(start: date.apply(hours: 6, minutes: 0, calendar: calendar), duration: 60*60)]
        
        scrollView = self.view as! CTimeScrollView
        scrollView.timeIntervals = .mins15
        scrollView.unavailableTimeIntervals = unavailableTimeIntervals
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

