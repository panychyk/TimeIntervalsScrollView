import Foundation

public protocol AvailabilityTimelineViewDelegate: AnyObject {
    
    func availabilityTimelineView(_ view: AvailabilityTimelineView, didSelectTimeInterval interval: DateInterval)
    func availabilityTimelineView(_ view: AvailabilityTimelineView, didUpdateSelectedTimeInterval interval: DateInterval)
    func availabilityTimelineView(_ view: AvailabilityTimelineView, didSelectReservation reservation: Reservation, sender: AvailabilityReservationView)
}
