//
//  CReservationView.swift
//  TimeScrollViewTest
//
//  Created by Dimitry Panychyk on 10/8/17.
//  Copyright © 2017 d'Man. All rights reserved.
//

import UIKit

class CReservationView: UIView {

    var reservation: ReservationModel!
    
    // Parameters:
    let reservationUserImageSize = CGSize(width: 24, height: 24)
    let borderWidth: CGFloat     = 1.0
    let contentHeight: CGFloat   = 50.0
    
    // Design:
    let fillColor   = UIColor(red: 169.0/255.0, green: 184.0/255.0, blue: 178.0/255.0, alpha: 1.0)
    let borderColor = UIColor(red: 28.0/255.0, green: 66.0/255.0, blue: 52.0/255.0, alpha: 1.0)
    
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
        context?.setLineWidth(borderWidth)
        context?.addRect(rect)
        context?.setFillColor(fillColor.cgColor)
        context?.fill(rect)
        context?.strokePath()
        borderColor.setStroke()
        let path = CGPath(rect: rect, transform: nil)
        context?.addPath(path)
        context?.drawPath(using: .fillStroke)
        
        let image = UIImage(named: self.reservation.hostImageName)
        
        let imagePoint = CGPoint(x: rect.midX - CGFloat(reservationUserImageSize.width/2),
                                 y: rect.midY - CGFloat(reservationUserImageSize.height/2))
        image?.draw(in: CGRect(origin: imagePoint, size: reservationUserImageSize))
        
    }

}
