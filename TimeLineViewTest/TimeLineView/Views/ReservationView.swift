//
//  ReservationView.swift
//  TimeScrollViewTest
//
//  Created by Dimitry Panychyk on 10/8/17.
//  Copyright © 2017 d'Man. All rights reserved.
//

import UIKit

class ReservationView: UIView {

    var reservation: ReservationModel!
    
    // Parameters:
    var timeLineViewAppearance: TimeLineViewAppearance!
    
    convenience init(_ reservation: ReservationModel) {
        self.init()
        self.reservation = reservation
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    private func configure() {
        self.backgroundColor = .clear
        self.clipsToBounds = false
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let context = UIGraphicsGetCurrentContext()
        context?.setLineWidth(timeLineViewAppearance.reservationsViewBorderWidth)
        context?.addRect(rect)
        context?.setFillColor(timeLineViewAppearance.reservationsViewBackgroundColor.cgColor)
        context?.fill(rect)
        context?.strokePath()
        timeLineViewAppearance.reservationsViewBorderColor.setStroke()
        let path = CGPath(rect: rect, transform: nil)
        context?.addPath(path)
        context?.drawPath(using: .fillStroke)
        
        let image = UIImage(named: self.reservation.hostImageName)
        
        let imagePoint = CGPoint(x: rect.midX - CGFloat(timeLineViewAppearance.reservationsViewUserImageSize.width/2),
                                 y: rect.midY - CGFloat(timeLineViewAppearance.reservationsViewUserImageSize.height/2))
        image?.draw(in: CGRect(origin: imagePoint, size: timeLineViewAppearance.reservationsViewUserImageSize))
        
    }

}
