import Foundation
import UIKit

public extension String {
    
    func attributedString(font: UIFont, charSpace: Float, tintColor: UIColor) -> NSAttributedString {
        return NSAttributedString(
            string: self,
            attributes: [
                NSAttributedString.Key.kern: NSNumber(value: charSpace),
                NSAttributedString.Key.font: font,
                NSAttributedString.Key.foregroundColor: tintColor
            ]
        )
    }
}
