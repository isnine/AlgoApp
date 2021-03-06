//
//  UIColor+Utility.swift
//  AlgoApp
//
//  Created by Huong Do on 2/4/19.
//  Copyright © 2019 Huong Do. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}

extension UIColor {
    static func primaryColor() -> UIColor {
        switch AppConfigs.shared.currentTheme {
        case .light: return .white
        case .dark: return UIColor(rgb: 0x333333)
        }
    }
    
    static func secondaryColor() -> UIColor {
        switch AppConfigs.shared.currentTheme {
        case .light: return appOrangeColor()
        case .dark: return appYellowColor()
        }
    }
    
    static func appYellowColor() -> UIColor {
        return UIColor(rgb: 0xFCCA52)
    }
    
    static func appOrangeColor() -> UIColor {
        return UIColor(rgb: 0xF16827)
    }
    
    static func appBlueColor() -> UIColor {
        return UIColor(rgb: 0x618ED9)
    }
    
    static func appGreenColor() -> UIColor {
        return UIColor(rgb: 0x66BD90)
    }
    
    static func appRedColor() -> UIColor {
        return UIColor(rgb: 0xE23B3B)
    }
    
    static func appPurpleColor() -> UIColor {
        return UIColor(rgb: 0x8774D8)
    }

    static func borderColor() -> UIColor {
        switch AppConfigs.shared.currentTheme {
        case .light: return UIColor(rgb: 0xc3c3c3)
        case .dark: return UIColor(rgb: 0xc3c3c3).withAlphaComponent(0.2)
        }
    }
    
    static func subtitleTextColor() -> UIColor {
        return UIColor(rgb: 0x999999)
    }
    
    static func titleTextColor() -> UIColor {
        switch AppConfigs.shared.currentTheme {
        case .light: return UIColor(rgb: 0x333333)
        case .dark: return .white
        }
    }
    
    static func backgroundColor() -> UIColor {
        switch AppConfigs.shared.currentTheme {
        case .light: return UIColor(rgb: 0xf4f4f4)
        case .dark: return UIColor(rgb: 0x424242)
        }
    }
    
    static func selectedBackgroundColor() -> UIColor {
        switch AppConfigs.shared.currentTheme {
        case .light: return UIColor(rgb: 0xe0e0e0)
        case .dark: return UIColor(rgb: 0x242424)
        }
    }
}
