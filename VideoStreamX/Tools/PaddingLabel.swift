//
//  PaddingLabel.swift
//  VideoStreamX
//
//  Created by kaylla on 2025/3/7.
//

import UIKit

class PaddingLabel: UILabel {
    
    var textInsets = UIEdgeInsets.zero {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + textInsets.left + textInsets.right,
            height: size.height + textInsets.top + textInsets.bottom
        )
    }
    
    override func sizeToFit() {
        super.sizeToFit()
        let newFrame = frame.insetBy(
            dx: -(textInsets.left + textInsets.right),
            dy: -(textInsets.top + textInsets.bottom)
        )
        frame = newFrame
    }
}
