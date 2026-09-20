//
//  TransactionFormSheet.swift
//  Cadence
//
//  Created by Arseny Solyanov on 11/11/26.
//

import SwiftUI
import SwiftData

struct TransactionFormSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var transaction: Transaction?
    
    @State private var type: TransactionType = .expense
    @State private var title: String = ""
    @State private var amountString: String = ""
    @State private var currencySymbol: String = "₽"
    @State private var category: TransactionCategory = .food
    @State private var date: Date = .now
    @State private var note: String = ""
    
    private var isEditing: Bool { transaction != nil }
    
    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        (Double(amountString.replacingOccurrences(of: ",", with: ".")) ?? 0) > 0
    }
    
    // Фильтр категорий под выбранный тип (расход / доход)
    private var availableCategories: [TransactionCategory] {
        switch type {
        case .expense:
            return [.food, .transport, .shopping, .entertainment, .health, .housing, .other]
        case .income:
            return [.salary, .freelance, .investments, .other]
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Переключатель Типа (Расход / Доход)
                Section {
                    Picker("Тип", selection: $type) {
                        ForEach(TransactionType.allCases, id: \.self) { t in
                            Text(t.rawValue).tag(t)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: type) { _, newType in
                        // Автоматически переключаем категорию на первую доступную
                        if !availableCategories.contains(category) {
                            category = newType == .expense ? .food : .salary
                        }
                    }
                }
                
                // Сумма и Название
                Section("Детали операции") {
                    HStack {
                        TextField("0", text: $amountString)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .keyboardType(.decimalPad)
                        
                        Text(currencySymbol)
                            .font(.title2.bold())
                            .foregroundStyle(.secondary)
                    }
                    
                    TextField("Название (например, Продукты)", text: $title)
                    
                    DatePicker("Дата", selection: $date, displayedComponents: [.date])
                }
                
                // Выбор категории
                Section("Категория") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                        ForEach(availableCategories, id: \.self) { cat in
                            Button {
                                category = cat
                            } label: {
                                VStack(spacing: 6) {
                                    ZStack {
                                        Circle()
                                            .fill(category == cat ? Color(hex: cat.defaultColorHex) : Color(hex: cat.defaultColorHex).opacity(0.15))
                                            .frame(width: 44, height: 44)
                                        
                                        Image(systemName: cat.iconName)
                                            .font(.subheadline.bold())
                                            .foregroundStyle(category == cat ? .white : Color(hex: cat.defaultColorHex))
                                    }
                                    
                                    Text(cat.rawValue)
                                        .font(.system(size: 10, weight: category == cat ? .bold : .regular))
                                        .lineLimit(1)
                                        .foregroundStyle(category == cat ? Color.primary : .secondary)
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 6)
                }
                
                // Заметка
                Section("Заметка (необязательно)") {
                    TextField("Дополнительный комментарий", text: $note)
                }
            }
            .navigationTitle(isEditing ? "Редактирование" : "Новая операция")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Сохранить" : "Добавить") {
                        save()
                    }
                    .disabled(!isValid)
                }
            }
            .onAppear {
                guard let transaction else { return }
                title = transaction.title
                let isInt = transaction.amount.truncatingRemainder(dividingBy: 1) == 0
                amountString = isInt ? String(format: "%.0f", transaction.amount) : String(format: "%.2f", transaction.amount)
                currencySymbol = transaction.currencySymbol
                type = transaction.type
                category = transaction.category
                date = transaction.date
                note = transaction.note
            }
        }
    }
    
    private func save() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
        let parsedAmount = Double(amountString.replacingOccurrences(of: ",", with: ".")) ?? 0.0
        
        if let transaction {
            transaction.title = trimmedTitle
            transaction.amount = parsedAmount
            transaction.currencySymbol = currencySymbol
            transaction.type = type
            transaction.category = category
            transaction.date = date
            transaction.note = note
        } else {
            let newTx = Transaction(
                title: trimmedTitle,
                amount: parsedAmount,
                currencySymbol: currencySymbol,
                date: date,
                type: type,
                category: category,
                note: note
            )
            modelContext.insert(newTx)
        }
        
        try? modelContext.save()
        dismiss()
    }
}
