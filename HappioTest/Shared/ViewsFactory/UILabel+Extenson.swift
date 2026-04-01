//
//  UILabel+Extenson.swift
//  HappioTest
//
//  Created by Vasyl Vasylchenko on 31.03.2026.
//

import UIKit

extension UILabel {
    
    static func makeLabel(
        font: UIFont,
        numberOfLines: Int = 0,
        textColor: UIColor = UIColor.black,
        translatesAutoresizingMaskIntoConstraints: Bool = false
    ) -> UILabel {
        let label = UILabel()
        label.font = font
        label.numberOfLines = numberOfLines
        label.textColor = textColor
        label.translatesAutoresizingMaskIntoConstraints = translatesAutoresizingMaskIntoConstraints
        return label
    }
}
