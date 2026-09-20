//
//  HabitDetailView.swift
//  Cadence
//
//  Created by Arseny Solyanov on 9/20/26.
//
import SwiftUI

struct HabitDetailView : View {
    @Bindable var habit: Habit
    @Environment(\.dismiss) private var dismiss
    
    @State private var displayedMonth: Date = .now
    
    private let calendar: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday =  2
        return cal
    }()
    
    private let weekdays = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Карточка статистики сверху
                statsHeaderCard
                
                // Календарь за месяц
                monthCalendarCard
            }
            .padding(16)
        }
        .background(AppTheme.Colors.background)
        .navigationTitle(habit.name)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Stats Header Card
    private var statsHeaderCard: some View {
        VStack(spacing: 16){
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(habit.tintColor.opacity(0.2))
                        .frame(width: 52, height: 52)
                    
                    Image(systemName: habit.iconName)
                        .font(.title2.bold())
                        .foregroundStyle(habit.tintColor)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(habit.name)
                        .font(.title3.bold())
                        .lineLimit(1)
                    
                    Text("Создана \(habit.cretedAt.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
                
                Spacer()
            }
            
            Divider()
            
            HStack {
                statItem(
                    title: "Серия",
                    value: "\(habit.currentStreak)",
                    subTitle: "дней подряд",
                    icon: "flame.fill",
                    iconColor: habit.tintColor
                )
                
                Spacer()
                
                statItem (
                    title: "На неделе",
                    value: "\(habit.weeklyCompletionCount)/7",
                    subTitle: "выполнено",
                    icon: "calendar.badge.checkmark",
                    iconColor: AppTheme.Colors.subAccent
                )
                
                Spacer()
                
                statItem (
                    title: "Всего",
                    value: "\(habit.completedDates.count)",
                    subTitle: "отметок",
                    icon: "checkmark.seal.fill",
                    iconColor: AppTheme.Colors.habitAccent
                )
            }
        }
        .padding(16)
        .glassEffect(.regular.tint(habit.tintColor.opacity(0.25)), in: RoundedRectangle(cornerRadius: AppTheme.Layout.cardRadius))
    }
    
    private func statItem(title: String, value: String, subTitle: String, icon: String, iconColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 4){
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(iconColor)
                Text(title)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
            
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
            
            Text(subTitle)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
    
    // MARK: - Month Calendar Card
    private var monthCalendarCard: some View {
        VStack(spacing: 14) {
            HStack{
                Text(monthYearString(from: displayedMonth))
                    .font(.headline)
                
                Spacer()
                
                HStack(spacing: 8) {
                    Button {
                        changeMonth(by: -1)
                    }  label: {
                        Image(systemName: "chevron.left")
                            .font(.subheadline.bold())
                    }
                    .buttonStyle(.glassProminent)
                    .buttonBorderShape(.circle)
                    
                    Button {
                        changeMonth(by: 1)
                    }  label: {
                        Image(systemName: "chevron.right")
                            .font(.subheadline.bold())
                    }
                    .buttonStyle(.glassProminent)
                    .buttonBorderShape(.circle)
                }
            }
            
            HStack(spacing: 0) {
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(Array(daysInMonthGrid().enumerated()), id: \.offset) { index, date in
                    if let date {
                        dayCell(date: date)
                    } else {
                        Color.clear
                            .frame(height: 36)
                    }
                }
            }
        }
        .padding(16)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: AppTheme.Layout.cardRadius))
    }
    
    private func dayCell(date: Date) -> some View {
        let isDone = habit.isCompleted(on: date)
        let isToday = calendar.isDateInToday(date)
        let dayNumber = calendar.component(.day, from: date)
        
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                habit.toggle(date: date)
            }
        } label: {
            Text("\(dayNumber)")
                .font(.system(size: 14, weight: isToday ? .bold: .regular))
                .frame(maxWidth: .infinity)
                .frame(height: 36)
                .foregroundStyle(isDone ? .white : .primary)
                .background {
                    if isDone {
                        Circle().fill(habit.tintColor)
                    } else if isToday {
                        Circle().fill(Color.primary.opacity(0.08))
                    }
                }
                .overlay {
                    if isToday && !isDone {
                        Circle().strokeBorder(habit.tintColor, lineWidth: 1.5)
                    }
                }
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.impact(weight: .light), trigger: isDone)
    }
    
    // MARK: - Calendar Helpers
    private func changeMonth(by value: Int) {
        if let next = calendar.date(byAdding: .month, value: value, to: displayedMonth) {
            displayedMonth = next
        }
    }
    
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: date).capitalized
    }
    
    private func daysInMonthGrid() -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth),
              let monthRange = calendar.range(of: .day, in: .month, for: displayedMonth) else {
            return []
        }
        
        let firstDayOfMonth = monthInterval.start
        // weekday в Gregorian: 1 - воскресенье 2 - понедельник
        // приводим к 0 (пн)
        let weekday = calendar.component(.weekday, from: firstDayOfMonth)
        let leadingSpaces = (weekday - calendar.firstWeekday + 7) % 7
        
        var result: [Date?] = Array (repeating: nil, count: leadingSpaces)
        
        for day in 0..<monthRange.count {
            if let date = calendar.date(byAdding: .day, value: day, to: firstDayOfMonth) {
                result.append(date)
            }
        }
        
        return result
    }
}
