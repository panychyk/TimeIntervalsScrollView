import Foundation

public protocol AvailabilityTimelineViewDataSource: AnyObject {
    
    func hasConflictWithReservations(in view: AvailabilityTimelineView) -> Bool
    func timeStep(for view: AvailabilityTimelineView) -> AvailabilityTimelineInterval
    func maximumReservableIntervalInSeconds(for view: AvailabilityTimelineView) -> Int
    func viewModel(for view: AvailabilityTimelineView) -> AvailabilityTimelineViewModel
}
