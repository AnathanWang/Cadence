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
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: AppTheme.Layout.spacing){
                    ForEach (habits) { habit in
                        HabitRow(habit: habit)
                    }
                }
                .padding()
            }
            .background(AppTheme.Colors.background)
            .navigationTitle("Привычки")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isPresentedAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .glassEffect(.regular.interactive(), in: Circle())
                }
            }
            .sheet(isPresented: $isPresentedAddSheet) {
                AddHabitSheet()
            }
            .overlay {
                if habits.isEmpty {
                    ContentUnavailableView(
                        "Пока нет привычек",
                        systemImage: "star",
                        description: Text("Нажми +, чтобы добавить первую")
                    )
                }
            }
        }
    }
    
    private func deleteHabit(_ habit: Habit) {
            modelContext.delete(habit)
    }
}
