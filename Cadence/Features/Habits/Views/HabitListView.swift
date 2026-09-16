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
    
    var body: some View {
        NavigationStack {
            ScrollView{
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(habits) { habit in
                        HabitCard(habit: habit)
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
                .padding(16)
            }
            .background(AppTheme.Colors.background)
            .navigationTitle(Text("Привычки"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isPresentedAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .buttonStyle(.glassProminent)
                    .buttonBorderShape(.circle)
                }
            }
            .sheet(isPresented: $isPresentedAddSheet) {
                HabitFormSheet(habit: nil)
            }
            .sheet(item: $habitToEdit) {
                habit in HabitFormSheet(habit: habit)
            }
            .overlay {
                if habits.isEmpty {
                    ContentUnavailableView("Пока нет привычек", systemImage: "star", description: Text("Нажмите на  + чтобы добавить первую"))
                }
            }
        }
    }
    
    private func deleteHabit(_ habit: Habit) {
            modelContext.delete(habit)
    }
}
