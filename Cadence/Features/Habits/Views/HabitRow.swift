//
//  HabitRow.swift
//  Cadence
//
//  Created by Arseny Solyanov on 9/15/26.
//
import SwiftUI

struct HabitRow: View {
    let habit: Habit
    
    var body: some View {
        HStack {
            Image(systemName: habit.iconName)
                .font(.title2)
                .foregroundStyle(AppTheme.Colors.habitAccent)
            
            VStack(alignment: .leading, spacing: 4){
                Text(habit.name)
                    .font(.headline)
                Text("Серия: \(habit.currentStreak) дн.")
                    .font(.caption)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
            
            Spacer()
            
            Button{
                habit.toggleToday()
            } label: {
                Image(systemName: habit.isCompletedToday ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(habit.isCompletedToday ? AppTheme.Colors.habitAccent : .secondary)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: AppTheme.Layout.cardRadius))
    }
}
