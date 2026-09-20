//
//  SubscriptionFormSheet.swift
//  Cadence
//
//  Created by Arseny Solyanov on 11/5/26.
//

import SwiftUI
import SwiftData

struct SubscriptionFormSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var subsriprion: Subscription?
    
    @State private var name: String = ""
    @State private var priceString: String = ""
    @State private var currencySymbol: String = "₽"
    @State private var billingCycle: BillingCycle = .monthly
    @State private var paymentDate: Date = .now
    @State private var selectedIcon: String = "creditcard.fill"
    @State private var selectedColorHex: String = "8B5CF6"
    
    private let colorOptions: [String] = [
        "8B5CF6", // violet (subAccent)
        "5E5CE6", // indigo
        "0A84FF", // blue
        "FF375F", // pink
        "FF9F43", // amber
        "34C759", // green
        "30D5C8", // teal
        "FF8B66"  // coral
    ]
    
    private let iconOptions = [
        "creditcard.fill",
        "play.tv.fill",
        "music.note",
        "icloud.fill",
        "gamecontroller.fill",
        "globe",
        "dumbbell.fill",
        "cart.fill"
    ]
    
    private var isEditing: Bool { subsriprion != nil }
    
    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && (Double(priceString.replacingOccurrences(of: ",", with: ".")) ?? 0) > 0   
    }
    
    var body: some View {
        NavigationStack {
            Form {
                //Основная информация
                Section("Основное") {
                    TextField("Название (например, Яндекс Плюс", text: $name)
                    
                    HStack {
                        TextField("Стоимость", text: $priceString)
                            .keyboardType(.decimalPad)
                        
                        Text(currencySymbol)
                            .foregroundStyle(.secondary)
                    }
                    
                    Picker("Период списания", selection: $billingCycle) {
                        ForEach(BillingCycle.allCases, id: \.self) { cycle in
                            Text(cycle.rawValue).tag(cycle)
                        }
                    }
                    
                    DatePicker("Дата списания", selection: $paymentDate, displayedComponents: .date)
                }
                
                Section("Иконка") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 14) {
                        ForEach(iconOptions, id: \.self) { icon in
                            Button {
                                selectedIcon = icon
                            } label: {
                                Image(systemName: icon)
                                    .font(.title2)
                                    .frame(width: 48, height: 48)
                                    .foregroundStyle(selectedIcon == icon ? .white : Color(hex: selectedColorHex))
                                    .background(Circle().fill(selectedIcon == icon ? Color(hex: selectedColorHex) : .clear)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 6)
                }
                
                Section("Цвет") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 14) {
                        ForEach(colorOptions, id: \.self) { hex in
                            Button {
                                selectedColorHex = hex
                            } label: {
                                Circle()
                                    .fill(Color(hex: hex))
                                    .frame(width: 36, height: 36)
                                    .overlay{
                                        if selectedColorHex == hex {
                                            Circle()
                                                .strokeBorder(.primary, lineWidth: 2)
                                                .padding(-3)
                                        }
                                    }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 6)
                }
            }
            .navigationTitle(isEditing ? "Редактирование" : "Новая подписка")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction){
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
                guard let subsriprion else { return }
                name = subsriprion.name
                let isInt = subsriprion.price.truncatingRemainder(dividingBy: 1) == 0
                priceString = isInt ? String(format: "%.0f", subsriprion.price) : String (format: "%.2f", subsriprion.price)
                currencySymbol = subsriprion.currencySymbol
                billingCycle = subsriprion.billingCycle
                paymentDate = subsriprion.firstPaymentDate
                selectedIcon = subsriprion.iconName
                selectedColorHex = subsriprion.tintColorHex
            }
        }
    }
    
    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        let parsedPrice = Double(priceString.replacingOccurrences(of: ",", with: ".")) ?? 0.0
        
        if let subsriprion {
            subsriprion.name = trimmedName
            subsriprion.price = parsedPrice
            subsriprion.currencySymbol = currencySymbol
            subsriprion.billingCycle = billingCycle
            subsriprion.firstPaymentDate = paymentDate
            subsriprion.iconName = selectedIcon
            subsriprion.tintColorHex = selectedColorHex
        } else {
            let newSub = Subscription(
                name: trimmedName,
                price: parsedPrice,
                currencySymbol: currencySymbol,
                billingCycle: billingCycle,
                firstPaymentDate: paymentDate,
                iconName: selectedIcon,
                tintColorHex: selectedColorHex
            )
            modelContext.insert(newSub)
        }
        
        try? modelContext.save()
        dismiss()
    }
}
