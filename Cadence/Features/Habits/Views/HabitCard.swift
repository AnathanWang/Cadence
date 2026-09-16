//
//  HabitCard.swift
//  Cadence
//
//  Created by Arseny Solyanov on 9/16/26.
//
import SwiftUI

struct HabitCard: View {
    let habit: Habit
    
    private static let weekdaySymbols = ["П", "В", "С", "Ч", "П", "C", "В"]
    
    private var mondayCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2
        return calendar
    }
    
    private var weekDates: [Date] {
        guard let weekStart = mondayCalendar.dateInterval(of: .weekOfYear, for: .now)?.start else {
            return []
        }
        return (0..<7).compactMap {
            mondayCalendar.date(byAdding: .day, value: $0, to: weekStart)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Верхняя строка Стрик и кнопки отметки
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 3) {
                        Text("\(habit.currentStreak)")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                        Image(systemName: "flame.fill")
                            .font(.title3)
                            .foregroundStyle(habit.tintColor)
                    }
                    Text("ДНЕЙ")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Button (action: toggleHabit){
                    Image(systemName: "checkmark")
                        .font(.subheadline.bold())
                        .frame(width: 38, height: 38)
                        .opacity(habit.isCompletedToday ? 1 : 0.35)
                }
                .buttonStyle(.glassProminent)
                .buttonBorderShape(.circle)
                .tint(habit.tintColor)
            }
            
            HStack(spacing: 6) {
                Image(systemName: habit.iconName)
                    .font(.headline)
                    .foregroundStyle(habit.tintColor)
                Text(habit.name)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                Spacer(minLength: 4)
                Text("\(habit.weeklyCompletionCount)/7")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            HStack(spacing: 5) {
                ForEach(Array(weekDates.enumerated()), id: \.offset) { index, date in
                    let isToday = mondayCalendar.isDateInToday(date)
                    let isDone = habit.completedDates.contains { mondayCalendar.isDate($0, inSameDayAs: date)}
                    
                    Text(Self.weekdaySymbols[index])
                        .font(.caption2.weight(.semibold))
                        .frame(width:24, height: 24)
                        .foregroundStyle(isDone ? .white : .secondary)
                        .background {
                            Circle()
                                .fill(isDone ? habit.tintColor : Color.primary.opacity(0.07))
                        }
                        .overlay {
                            if isToday {
                                Circle().strokeBorder(habit.tintColor, lineWidth: 1.5)
                            }
                        }
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular.tint(habit.tintColor.opacity(0.4)), in: RoundedRectangle(cornerRadius: 24))
    }
    
    private func toggleHabit() {
        withAnimation(.spring(response: 3.0, dampingFraction: 0.7)) {
            habit.toggleToday()
        }
    }
}
