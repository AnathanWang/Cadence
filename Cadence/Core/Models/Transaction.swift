//
//  Transaction.swift
//  Cadence
//
//  Created by Arseny Solyanov on 11/10/26.
//

import Foundation
import SwiftUI
import SwiftData

enum TransactionType: String, Codable, CaseIterable {
    case expense = "Расход"
    case income = "Доход"
}

enum TransactionCategory: String, Codable, CaseIterable {
    //Расходы
    case food = "Еда и продукты"
    case transport = "Транспорт"
    case shopping = "Покупки"
    case entertainment = "Развлечения"
    case health = "Здоровье"
    case housing = "Жилье и дом"
    
    //Доходы
    case salary = "Зарплата"
    case freelance = "Фриланс"
    case investments = "Инвестиции"
    
    //Прочее
    case other = "Другое"
    
    var iconName: String {
        switch self {
        case .food: return "fork.knife"
        case .transport: return "car.fill"
        case .shopping: return "bag.fill"
        case .entertainment: return "popcorn.fill"
        case .health: return "heart.fill"
        case .housing: return "house.fill"
        case .salary: return "banknote.fill"
        case .freelance: return "laptopcomputer"
        case .investments: return "chart.line.uptrend.xyaxis"
        case .other: return "ellipsis.circle.fill"
        }
    }
    
    var defaultColorHex: String {
        switch self {
        case .food: return "FF9F43"
        case .transport: return "0A84FF"
        case .shopping: return "FF375F"
        case .entertainment: return "8B5CF6"
        case .health: return "FF453A"
        case .housing: return "FFD60A"
        case .salary: return "34C759"
        case .freelance: return "30D5C8"
        case .investments: return "5E5CE6"
        case .other: return "98989D"
        }
    }
}

@Model
final class Transaction {
    //MARK: - Properties
    var title: String = ""
    var amount: Double = 0.0
    var currencySymbol: String = "₽"
    var date: Date = Date.now
    var typeRaw: String = TransactionType.expense.rawValue
    var categoryRaw: String = TransactionCategory.other.rawValue
    var note: String = ""
    
    var type: TransactionType {
        get { TransactionType(rawValue: typeRaw) ?? .expense }
        set { typeRaw = newValue.rawValue}
    }
    
    var category: TransactionCategory {
        get { TransactionCategory(rawValue: categoryRaw) ?? .other }
        set { typeRaw = newValue.rawValue}
    }
    
    //MARK: - Init
    init(
        title: String,
        amount: Double,
        currencySymbol: String = "₽",
        date: Date = .now,
        type: TransactionType = .expense,
        category: TransactionCategory = .other,
        note: String = ""
    ) {
        self.title = title
        self.amount = amount
        self.currencySymbol = currencySymbol
        self.date = date
        self.typeRaw = type.rawValue
        self.categoryRaw = category.rawValue
        self.note = note
    }
}

//MARK: - Presentation Helpers
extension Transaction {
    var categoryColor: Color {
        Color(hex: category.defaultColorHex)
    }
    
    var formattedAmount: String {
        let isInteger = amount.truncatingRemainder(dividingBy: 1) == 0
        let formatted = isInteger ? String(format: "%.0f", amount) : String(format: "%.2f", amount)
        let prefix = type == .income ? "+" : "-"
        return "\(prefix)\(formatted) \(currencySymbol)"
    }
}
