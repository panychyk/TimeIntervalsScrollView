import UIKit

@MainActor protocol AvailabilityReservationViewDelegate: AnyObject {
    func reservation(view: AvailabilityReservationView, didTap reservation: Reservation)
}

public class AvailabilityReservationView: UIView {

    let reservation: Reservation
    
    private let timeLineViewAppearance: AvailabilityTimelineStyle
    
    private let imageView = UIImageView()
    
    weak var delegate: AvailabilityReservationViewDelegate?
    
    public init(_ reservation: Reservation, appearance: AvailabilityTimelineStyle) {
        self.reservation = reservation
        self.timeLineViewAppearance = appearance
        super.init(frame: .zero)
        setupUI()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        let imageSize = timeLineViewAppearance.reservationUserImageSize
        let imagePoint = CGPoint(
            x: bounds.midX - CGFloat(imageSize.width/2),
            y: bounds.midY - CGFloat(imageSize.height/2)
        )
        imageView.frame = CGRect(origin: imagePoint, size: imageSize)
    }
    
    private func setupUI() {
        backgroundColor = timeLineViewAppearance.reservationBackgroundColor
        layer.borderColor = timeLineViewAppearance.reservationBorderColor.cgColor
        layer.borderWidth = timeLineViewAppearance.reservationBorderWidth
        imageView.image = reservation.reservationImage
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onReservationTapAction(gesture:)))
        addGestureRecognizer(tapGesture)
    }
    
    private func setupLayout() {
        addSubview(imageView)
    }
    
    @objc private func onReservationTapAction(gesture: UITapGestureRecognizer) {
        delegate?.reservation(view: self, didTap: reservation)
    }
}
