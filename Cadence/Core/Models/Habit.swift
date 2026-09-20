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
    private var calendar: Calendar {
        var cal =  Calendar(identifier: .gregorian)
        cal.firstWeekday = 2
        return cal
    }
    
    var currentStreak: Int {
        let sortedUniqueDays = Set(completedDates.map { calendar.startOfDay(for: $0) })
            .sorted(by: >)
        guard let mostRecent = sortedUniqueDays.first else { return 0 }
        
        let today = calendar.startOfDay(for: .now)
        let daysSinceLastCompletion = calendar.dateComponents([.day], from: mostRecent, to: today).day ?? 0
        
        // стрик не сгорел если отметили сегодня или вчера
        guard daysSinceLastCompletion <= 1 else { return 0 }
        
        var streak = 1
        var previousDate = mostRecent
        
        for date in sortedUniqueDays.dropFirst() {
            let gap = calendar.dateComponents([.day], from: date, to: previousDate).day ?? 0
            if gap == 1 {
                streak += 1
                previousDate = date
            } else {
                break
            }
        }
        
        return streak
    }
    
    var isCompletedToday: Bool {
        isCompleted(on: .now)
    }
    
    func isCompleted(on date: Date) -> Bool {
        let target = calendar.startOfDay(for: date)
        return completedDates.contains { calendar.isDate($0, inSameDayAs: target) }
    }
    
    func toggleToday() {
        toggle(date: .now)
    }
    
    var weeklyCompletionCount: Int {
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: .now) else { return 0 }
        let datesThisWeek = completedDates.filter { weekInterval.contains($0)}
        //считаем только уникальные дни
        let uniqueDays = Set(datesThisWeek.map { calendar.startOfDay(for: $0) })
        return uniqueDays.count
    }
    
    func toggle(date: Date) {
        let targetDay =  calendar.startOfDay(for: date)
        if isCompleted(on: targetDay) {
            //удаляем все записи за этот день(очищая возможные дубликаты)
            completedDates.removeAll { calendar.isDate($0, inSameDayAs: targetDay) }
        } else {
            completedDates.append(targetDay)
        }
    }
}
