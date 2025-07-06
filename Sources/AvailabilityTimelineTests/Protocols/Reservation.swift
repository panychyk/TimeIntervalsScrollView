import Foundation
import UIKit

public protocol Reservation {
    var reservationImageURL: URL? { get }
    var reservationImage: UIImage? { get }
    var reservationStartDate: Date { get }
    var reservationEndDate: Date { get }
}
