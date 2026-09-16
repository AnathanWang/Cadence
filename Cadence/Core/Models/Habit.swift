//
//  Habit.swift
//  Cadence
//
//  Created by Arseny Solyanov on 9/15/26.
//

import Foundation
import SwiftUI
import SwiftData

@Model
final class Habit {
    // MARK: - Properties
    var name: String = ""
    var iconName: String = "star.fill"
    var tintColorHex: String = "5E5cE6"
    var cretedAt: Date = Date.now
    var completedDates: [Date] = []
    
    // MARK: - Init
    init(name: String, iconName: String = "star.fill", tintColorHex: String = "5E5CE6", createdAt: Date = .now) {
        self.name = name
        self.iconName = iconName
        self.tintColorHex = tintColorHex
        self.cretedAt = createdAt
        self.completedDates = []
    }
}

//MARK: - Streak logic
extension Habit {
    var currentStreak: Int {
        let calendar = Calendar.current
        let sortedDates = completedDates
            .map { calendar.startOfDay(for: $0) }
            .sorted(by: >)
        guard let mostRecent = sortedDates.first else { return 0 }
        
        let today = calendar.startOfDay(for: .now)
        let daysSinceLastCompletion = calendar.dateComponents([.day], from: mostRecent, to: today).day ?? 0
        
        guard daysSinceLastCompletion <= 1 else { return 0 }
        
        var streak = 1
        var previousDate = mostRecent
        
        for date in sortedDates {
            let gap = calendar.dateComponents([.day], from: previousDate, to: date).day ?? 0
            if gap == 1 {
                streak += 1
                previousDate = date
            } else if gap == 0 {
                continue
            } else {
                break
            }
        }
        
        return streak
    }
    
    var isCompletedToday: Bool {
        let calendar = Calendar.current
        return completedDates.contains(where: { calendar.isDateInToday($0) })
    }
    
    func toggleToday() {
        let calendar = Calendar.current
        if let index = completedDates.firstIndex(of: calendar.startOfDay(for: .now)) {
            completedDates.remove(at: index)
        } else {
            completedDates.append(.now)
        }
    }
    
    var weeklyCompletionCount: Int {
        var calendar =  Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: .now) else { return 0 }
        return completedDates.filter { weekInterval.contains($0) }.count
    }
}
