//
//  String+Attributes.swift
//  TimeScrollViewTest
//
//  Created by Dimitry Panychyk on 7/26/17.
//  Copyright © 2017 d'Man. All rights reserved.
//

import Foundation
import UIKit

extension String {
  
  func attributedString(font: UIFont, charSpace: Float, tintColor: UIColor, upperCase: Bool) -> NSAttributedString {
    let parameters = [NSAttributedStringKey.kern            : NSNumber(value: charSpace),
                      NSAttributedStringKey.font            : font,
                      NSAttributedStringKey.foregroundColor : tintColor]
    if upperCase {
      return NSAttributedString(string: self.uppercased(), attributes: parameters)
    } else {
      return NSAttributedString(string: self, attributes: parameters)
    }
  }
 
  func attributedString(font: UIFont, charSpace: Float, tintColor: UIColor) -> NSAttributedString {
    return self.attributedString(font: font, charSpace: charSpace, tintColor: tintColor, upperCase: false)
  }
  
}
