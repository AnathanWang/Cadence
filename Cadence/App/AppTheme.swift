//
//  AppTheme.swift
//  Cadence
//
//  Created by Arseny Solyanov on 9/15/26.
//
import SwiftUI

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000FF) / 255.0
        
        self.init(red: r, green: g, blue: b)
    }
}

enum AppTheme{
    enum Colors{
        static let indigo = Color(hex: "5E5CE6")
        static let coral = Color(hex: "FF8B66")
        
        static let habitAccent = Color(hex: "FF9F43")
        static let subAccent = Color(hex: "8B5CF6")
        static let financeAccent = Color(hex: "34C759")
        
        //Adaptive
        static let background = Color(light: "F5F5F7", dark: "1C1C1E")
        static let textSecondary = Color (light: "6E6E73", dark: "98989D")
    }
}

extension Color {
    init(light: String, dark: String){
        self.init(uiColor: UIColor{
            traits in traits.userInterfaceStyle == .dark ? UIColor(Color(hex: dark)) : UIColor(Color(hex: light))
        })
    }
}

extension AppTheme {
    enum Layout {
        static let cardRadius: CGFloat = 20
        static let buttonRadius: CGFloat = 14
        static let spacing: CGFloat = 16
    }
}
