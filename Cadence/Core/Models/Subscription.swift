//
//  Subscription.swift
//  Cadence
//
//  Created by Arseny Solyanov on 11/3/26.
//

import Foundation
import SwiftUI
import SwiftData

enum BillingCycle: String, Codable, CaseIterable {
    case monthly = "Месяц"
    case yearly = "Год"
    case weekly = "Неделя"
}

@Model
final class Subscription {
    //MARK: - Properties
    var name: String = ""
    var price: Double = 0.0
    var currencySymbol: String = "₽"
    var billingCycleRaw: String = BillingCycle.monthly.rawValue
    var firstPaymentDate: Date = Date.now
    var iconName: String = "creditcard.fill"
    var tintColorHex: String = "8B5CF6"
    var reminderEnabled: Bool = true
    var notes: String = ""
    
    var billingCycle: BillingCycle {
        get {BillingCycle(rawValue: billingCycleRaw) ?? .monthly}
        set { billingCycleRaw = newValue.rawValue }
    }
    
    //MARK: - Init
    init (
        name: String,
        price: Double,
        currencySymbol: String = "₽",
        billingCycle: BillingCycle = .monthly,
        firstPaymentDate: Date = .now,
        iconName: String = "creditcard.fill",
        tintColorHex: String = "8B5CF6",
        reminderEnabled: Bool = true,
        notes: String = ""
    ) {
        self.name = name
        self.price = price
        self.currencySymbol = currencySymbol
        self.billingCycleRaw = billingCycle.rawValue
        self.firstPaymentDate = firstPaymentDate
        self.iconName = iconName
        self.tintColorHex =  tintColorHex
        self.reminderEnabled = reminderEnabled
        self.notes = notes
    }
}

//MARK: - Computations & Dates
extension Subscription {
    var tintColor: Color {
        Color(hex: tintColorHex)
    }
    
    var monthlyEquivalentCost: Double {
        switch billingCycle {
        case .weekly:
            return price * 4.333
        case .monthly:
            return price
        case .yearly:
            return price / 12.0
        }
    }
    
    var nextPaymentDate: Date {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        var nextDate = calendar.startOfDay(for: firstPaymentDate)
        
        while nextDate < today {
            switch billingCycle {
            case .weekly:
                nextDate = calendar.date(byAdding: .day, value: 7, to: nextDate) ?? nextDate
            case .monthly:
                nextDate = calendar.date(byAdding: .month, value: 1, to: nextDate) ?? nextDate
            case .yearly:
                nextDate = calendar.date(byAdding: .year, value: 1, to: nextDate) ?? nextDate
            }
        }
        
        return nextDate
    }
    
    var daysUntilNextPayment: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let paymentDay = calendar.startOfDay(for: nextPaymentDate)
        return max(0, calendar.dateComponents([.day], from: today, to: paymentDay).day ?? 0)
    }
}
