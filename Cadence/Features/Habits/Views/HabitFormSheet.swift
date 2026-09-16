//
//  HabitFromSheet.swift
//  Cadence
//
//  Created by Arseny Solyanov on 9/16/26.
//
import SwiftUI
import SwiftData

struct HabitFormSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var habit: Habit?
    
    @State private var name: String = ""
    @State private var selectedIcon: String = "star.fill"
    @State private var selectedColorHex: String = "5E5CE6"
    
    private let colorOption: [String] = [
        "5E5CE6", // indigo
        "0A84FF", // blue
        "FF375F", // pink
        "34C759", // green
        "FF9F43", // amber
        "8B5CF6", // violet
        "30D5C8", // teal
        "FF8B66"  // coral
    ]
    
    private let iconOption = ["star.fill", "book.fill", "figure.walk", "drop.fill", "bed.double.fill", "leaf.fill", "pencil", "cup.and.saucer.fill"]
    
    private var isEditing: Bool { habit != nil }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Название") {
                    TextField("Например читать по 20 минут", text: $name)
                }
                
                Section("Иконка") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                        ForEach(iconOption, id: \.self) {
                            icon in iconButton(icon)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section("Цвет") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                        ForEach(colorOption, id: \.self) { hex in
                            Button {
                                selectedColorHex = hex
                            } label: {
                                Circle()
                                    .fill(Color(hex: hex))
                                    .frame(width: 36, height: 36)
                                    .overlay {
                                        if selectedColorHex == hex {
                                            Circle().strokeBorder(.primary, lineWidth: 2).padding(-3)
                                        }
                                    }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle(isEditing ? "Редактирование" : "Создание")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Готово" : "Добавить") {
                        save()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                guard let habit else { return }
                name = habit.name
                selectedIcon = habit.iconName
                selectedColorHex = habit.tintColorHex
            }
        }
    }
    
    private func iconButton(_ icon: String) -> some View {
        Button {
            selectedIcon = icon
        } label: {
            Image(systemName: icon)
                .font(.title2)
                .frame(width: 44, height: 44)
                .foregroundStyle(selectedIcon == icon ? .white : AppTheme.Colors.habitAccent)
                .background(
                    Circle()
                        .fill(selectedIcon == icon ? AppTheme.Colors.habitAccent : .clear)
                )
        }
        .buttonStyle(.plain)
    }
    
    private func save() {
        print("save called")
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        
        if let habit {
            habit.name = trimmedName
            habit.iconName = selectedIcon
            habit.tintColorHex = selectedColorHex
        } else {
            let newHabit = Habit(
                name: trimmedName,
                iconName: selectedIcon,
                tintColorHex: selectedColorHex
            )
            modelContext.insert(newHabit)
        }
        
        do {
            try modelContext.save()
        } catch {
            print("Ошибка сохранения привычки: \(error)")
        }
        dismiss()
    }
}
