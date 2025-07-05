//
//  ViewController.swift
//  AvailabilityTimeline
//
//  Created by Dima Panychyk on 7/6/25.
//

import UIKit
import AvailabilityTimeline

class ViewController: UIViewController {

    private let timeIntervalScrollView = AvailabilityTimelineScrollView()
    private let timeIntervalScrollView2 = AvailabilityTimelineScrollView()
    
    let timeLineViewModel = AvailabilityTimelineViewModel()
    let synchronizer = ScrollSynchronizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
    }
    
    private func setupUI() {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let date = Date(timeInterval: TimeInterval(TimeZone.current.secondsFromGMT()), since: Date())
        let availableIntervals = [
            DateInterval(start: date.apply(hours: 0, minutes: 0, calendar: calendar), duration: 3*60*60),
            DateInterval(start: date.apply(hours: 7, minutes: 0, calendar: calendar), duration: 60*60),
        ]

        let reservations = [
            ReservationModel(reservationId: 1, reservationTimeInterval: DateInterval(start: date.apply(hours: 8, minutes: 0, calendar: calendar), duration: 2*60*60), hostName: "Second Best Friend"),
            ReservationModel(reservationId: 2, reservationTimeInterval: DateInterval(start: date.apply(hours: 12, minutes: 30, calendar: calendar), duration: 15*60), hostName: "Second Best Friend"),
            ReservationModel(reservationId: 3, reservationTimeInterval: DateInterval(start: date.apply(hours: 13, minutes: 00, calendar: calendar), duration: 60*60), hostName: "Second Best1 Friend"),
            ReservationModel(reservationId: 4, reservationTimeInterval: DateInterval(start: date.apply(hours: 14, minutes: 00, calendar: calendar), duration: 30*60), hostName: "Second Best1 Friend"),
            ReservationModel(reservationId: 5, reservationTimeInterval: DateInterval(start: date.apply(hours: 19, minutes: 30, calendar: calendar), duration: 30*60), hostName: "Second Best1 Friend"),
            ReservationModel(reservationId: 6, reservationTimeInterval: DateInterval(start: date.apply(hours: 23, minutes: 30, calendar: calendar), duration: 30*60), hostName: "Second Best1 Friend")
        ]

        let selectedInterval = DateInterval(start: date.apply(hours: 6, minutes: 30, calendar: calendar), duration: 45*60)
        
        timeLineViewModel.availableIntervals = availableIntervals
        timeLineViewModel.reservations = reservations
        timeLineViewModel.selectedInterval = selectedInterval
        
        timeIntervalScrollView.delegate = self
        timeIntervalScrollView2.delegate = self
        synchronizer.register(scrollView: timeIntervalScrollView)
        synchronizer.register(scrollView: timeIntervalScrollView2)
        
        let timeLineView = AvailabilityTimelineView(parent: timeIntervalScrollView)
        timeIntervalScrollView.timeLineView = timeLineView
        timeLineView.dataSource = self
        timeLineView.delegate = self
        timeLineView.date = Date().dateWithZeroHourAndMinute(calendar)!
        timeIntervalScrollView.applyContentSize()
        timeLineView.invalidate()
        
        let timeLineView2 = AvailabilityTimelineView(parent: timeIntervalScrollView2)
        timeIntervalScrollView2.timeLineView = timeLineView2
        timeLineView2.dataSource = self
        timeLineView2.delegate = self
        timeLineView2.date = Date().dateWithZeroHourAndMinute(calendar)!
        timeIntervalScrollView2.applyContentSize()
        timeLineView2.invalidate()
        timeIntervalScrollView2.scroll(date: date.apply(hours: 1, minutes: 00, calendar: calendar), position: .center, animate: false)
    }
    
    private func setupLayout() {
        let stackView = UIStackView(arrangedSubviews: [
            timeIntervalScrollView,
            timeIntervalScrollView2
        ])
        stackView.axis = .vertical
        view.addSubview(stackView)
        view.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            timeIntervalScrollView.heightAnchor.constraint(equalToConstant: 70),
            timeIntervalScrollView2.heightAnchor.constraint(equalToConstant: 70),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

extension ViewController: AvailabilityTimelineViewDelegate, AvailabilityTimelineViewDataSource {
    func availabilityTimelineView(_ view: AvailabilityTimelineView, didSelectTimeInterval interval: DateInterval) {
        print("newDateInterval startDate = \(interval.start) \nendDate = \(interval.end)")
    }
    
    func availabilityTimelineView(_ view: AvailabilityTimelineView, didUpdateSelectedTimeInterval interval: DateInterval) {
        print("newDateInterval startDate = \(interval.start) \nendDate = \(interval.end)")
    }
    
    func availabilityTimelineView(_ view: AvailabilityTimelineView, didSelectReservation reservation: any Reservation, sender: AvailabilityReservationView) {
        print("open reservation at startDate = \(reservation.reservationStartDate) \nendDate = \(reservation.reservationEndDate)")
    }
    
    func hasConflictWithReservations(in view: AvailabilityTimelineView) -> Bool {
        false
    }
    
    func timeStep(for view: AvailabilityTimelineView) -> AvailabilityTimelineInterval {
        .mins15
    }
    
    func maximumReservableIntervalInSeconds(for view: AvailabilityTimelineView) -> Int {
        let maxIntervalTwoHours = 2*60*60
        return maxIntervalTwoHours
    }
    
    func viewModel(for view: AvailabilityTimelineView) -> AvailabilityTimelineViewModel {
        timeLineViewModel
    }
}

extension ViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        synchronizer.sync(from: scrollView)
    }
}
