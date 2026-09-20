//
//  HabitListView.swift
//  Cadence
//
//  Created by Arseny Solyanov on 9/15/26.
//
import SwiftUI
import SwiftData

struct HabitListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Habit.cretedAt, order: .reverse) private var habits: [Habit]
    
    @State private var isPresentedAddSheet: Bool = false
    @State private var habitToEdit: Habit?
    
    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
    
    private var completedTodayCount: Int {
        habits.filter { $0.isCompletedToday }.count
    }
    
    var body: some View {
        NavigationStack {
            ScrollView{
                VStack(spacing: 16) {
                    //MARK: - Кастомная шапка
                    headerView
                
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(habits) { habit in
                            NavigationLink (value: habit) {
                                HabitCard(habit: habit)
                            }
                            .buttonStyle(.plain)
                            .contextMenu {
                                Button {
                                    habitToEdit = habit
                                } label: {
                                    Label("Изменить", systemImage: "pencil")
                                }
                                Button (role: .destructive) {
                                    withAnimation() {modelContext.delete(habit)}
                                } label: {
                                    Label("Удалить", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
                .padding(16)
            }
            .background(AppTheme.Colors.background)
            .navigationTitle(Text("Привычки"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar (.hidden, for: .navigationBar)
            .sheet(isPresented: $isPresentedAddSheet) {
                HabitFormSheet(habit: nil)
            }
            .sheet(item: $habitToEdit) {
                habit in HabitFormSheet(habit: habit)
            }
            .navigationDestination(for: Habit.self) { habit in
                HabitDetailView(habit: habit)
            }
            .overlay {
                if habits.isEmpty {
                    ContentUnavailableView("Пока нет привычек", systemImage: "star", description: Text("Нажмите на  + чтобы добавить первую"))
                }
            }
        }
    }
    
    //MARK: - Header View
    private var headerView: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Привычки")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                
                if !habits.isEmpty {
                    HStack(spacing: 6) {
                        Text("\(completedTodayCount) из \(habits.count) закрыто")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(AppTheme.Colors.textSecondary)
                        
                        if completedTodayCount ==  habits.count && !habits.isEmpty {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(AppTheme.Colors.habitAccent)
                                .font(.caption)
                        }
                    }
                } else {
                    Text("Начните формировать рутину")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
            }
            
            Spacer()
            
            Button {
                isPresentedAddSheet = true
            } label: {
                Image(systemName: "plus")
                    .font(.title3.bold())
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.glassProminent)
            .buttonBorderShape(.circle)
        }
        .padding(.top, 4)
    }
    
    private func deleteHabit(_ habit: Habit) {
            modelContext.delete(habit)
    }
}
