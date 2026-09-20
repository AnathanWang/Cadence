//
//  DashboardView.swift
//  Cadence
//
//  Created by Arseny Solyanov on 11/12/26.
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query private var habits: [Habit]
    @Query private var subscriptions: [Subscription]
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]
    
    //MARK: - Расчеты привычек
    private var completedTodayCount: Int {
        habits.filter { $0.isCompletedToday }.count
    }
    
    private var habitProgress: Double {
        guard !habits.isEmpty else { return 0 }
        return Double(completedTodayCount) / Double(habits.count)
    }
    
    //MARK: - Расчеты финансов
    private var totalBalance: Double {
        let income = transactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
        let expense = transactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
        return income - expense
    }
    
    //MARK: - Расчеты подписок
    private var upcomingSubscription: Subscription? {
        subscriptions.min(by: { $0.daysUntilNextPayment < $1.daysUntilNextPayment })
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack (spacing: 20) {
                    // 1. Хедер даты
                    headerView
                    
                    // 2. Сводка привычек дня
                    habitsSection
                    
                    // 3. Сводка финансов
                    financeSection
                    
                    // 4. Сводка подписок
                    subscriptionsSection
                }
                .padding(16)
            }
            .background(AppTheme.Colors.background)
            .toolbar(.hidden, for: .navigationBar)
        }
    }
    
    //MARK: - Header
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(currentDateFormatted.uppercased())
                .font(.caption.weight(.bold))
                .foregroundStyle(AppTheme.Colors.textSecondary)
            
            Text("Обзор дня")
                .font(.system(size: 32, weight: .bold, design: .rounded))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 4)
    }
    
    //MARK: - Habits section
    private var habitsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Привычки", systemImage: "star.fill")
                    .font(.headline)
                    .foregroundStyle(AppTheme.Colors.indigo)
                
                Spacer()
                
                Text("\(completedTodayCount) из \(habits.count)")
                    .font(.subheadline.bold())
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
            
            if habits.isEmpty {
                emptySectionText("Нет активных привычек")
            } else {
                //Прогресс-бар
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.primary.opacity(0.08))
                            .frame(height: 8)
                        
                        Capsule()
                            .fill(AppTheme.Colors.indigo)
                            .frame(width: max(0, geo.size.width * habitProgress), height: 8)
                            .animation(.spring(response: 0.4), value: habitProgress)
                    }
                }
                .frame(height: 8)
                
                // Горизонтальный скролл быстрых привычек
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(habits) { habit in
                            quickHabitPill(habit: habit)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding(16)
        .glassEffect(.regular.tint(AppTheme.Colors.indigo.opacity(0.18)), in: RoundedRectangle(cornerRadius: AppTheme.Layout.cardRadius))
    }
    
    // Плашка быстрой отметки привычки
    private func quickHabitPill(habit: Habit) -> some View {
        let isDone = habit.isCompletedToday
        
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                habit.toggleToday()
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: isDone ? "checkmark.circle.fill" : habit.iconName)
                    .font(.subheadline.bold())
                    .foregroundStyle(isDone ? .white : habit.tintColor)
                
                Text(habit.name)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(isDone ? .white : Color.primary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background {
                if isDone {
                    Capsule().fill(habit.tintColor)
                } else {
                    Capsule().fill(Color.primary.opacity(0.06))
                }
            }
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.impact(weight: .light), trigger: isDone)
    }
    
    //MARK: - Finance Section
    private var financeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Баланс финансов", systemImage: "chart.line.uptrend.xyaxis")
                .font(.headline)
                .foregroundStyle(AppTheme.Colors.financeAccent)
            
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(formatCurrency(totalBalance))
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(totalBalance >=  0 ? Color.primary : AppTheme.Colors.coral)
                
                Text("₽")
                    .font(.title3.bold())
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                
                Spacer()
                
                Text("\(transactions.count) записей")
                    .font(.caption)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
        }
        .padding(16)
        .glassEffect(.regular.tint(AppTheme.Colors.financeAccent.opacity(0.18)), in: RoundedRectangle(cornerRadius: AppTheme.Layout.cardRadius))
    }
    
    //MARK: - Subscriptions Sections
    private var subscriptionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Подписки", systemImage: "creditcard.fill")
                .font(.headline)
                .foregroundStyle(AppTheme.Colors.subAccent)
            
            if let upcoming = upcomingSubscription {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(upcoming.tintColor.opacity(0.18))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: upcoming.iconName)
                            .font(.subheadline.bold())
                            .foregroundStyle(upcoming.tintColor)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(upcoming.name)
                            .font(.subheadline.weight(.semibold))
                        
                        Text(dueText(for: upcoming))
                            .font(.caption)
                            .foregroundStyle(upcoming.daysUntilNextPayment <= 3 ? AppTheme.Colors.coral : AppTheme.Colors.textSecondary)
                    }
                    
                    Spacer()
                    
                    Text("\(String(format: "%.0f", upcoming.price)) \(upcoming.currencySymbol)")
                        .font(.subheadline.bold())
                }
            } else {
                emptySectionText("Нет активных подписок")
            }
        }
        .padding(16)
        .glassEffect(.regular.tint(AppTheme.Colors.subAccent.opacity(0.18)), in: RoundedRectangle(cornerRadius: AppTheme.Layout.cardRadius))
    }
    
    //MARK: - Helpers
    private func emptySectionText(_ text: String) -> some View {
        Text(text)
            .font(.caption)
            .foregroundStyle(AppTheme.Colors.textSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 4)
    }
    
    private var currentDateFormatted: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "EEEE, d MMMM"
        return formatter.string(from: .now)
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let isInt = value.truncatingRemainder(dividingBy: 1) == 0
        return isInt ? String(format: "%.0f", value) : String(format: "%.2f", value)
    }
    
    private func dueText(for sub: Subscription) -> String {
        let days =  sub.daysUntilNextPayment
        if days == 0 { return "Оплата сегодня" }
        if days == 1 { return "Оплата завтра" }
        return "Списание через \(days) дн."
    }
}
