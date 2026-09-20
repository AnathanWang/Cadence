//
//  FinanceView.swift
//  Cadence
//
//  Created by Arseny Solyanov on 11/11/26.
//

import SwiftUI
import SwiftData

struct FinanceView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]
    
    @State private var isPresentedAddSheet: Bool = false
    @State private var transactionToEdit: Transaction?
    @State private var selectedFilter: TransactionFilter = .all
    
    enum TransactionFilter: String, CaseIterable {
        case all = "Все"
        case expenses = "Расходы"
        case income = "Доходы"
    }
    
    //MARK: - Вычисления аналитики
    private var totalIncome: Double {
        transactions
            .filter { $0.type == .income}
            .reduce(0) { $0 + $1.amount}
    }
    
    private var totalExpenses: Double {
        transactions
            .filter { $0.type == .expense }
            .reduce(0) { $0 + $1.amount }
    }
    
    private var balance: Double {
        totalIncome - totalExpenses
    }
    
    private var filteredTransactions: [Transaction] {
        switch selectedFilter {
        case .all:
            return transactions
        case .expenses:
            return transactions.filter { $0.type == .expense }
        case .income:
            return transactions.filter { $0.type == .income }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    //шапка экрана
                    headerView
                    
                    //Карточка баланса
                    balanceSummaryCard
                    
                    //Фильтр списка
                    if !transactions.isEmpty {
                        Picker("Фильтр", selection: $selectedFilter) {
                            ForEach(TransactionFilter.allCases, id: \.self) { filter in
                                Text(filter.rawValue).tag(filter)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.top, 4)
                        
                        //Список операций
                        LazyVStack(spacing: 10) {
                            ForEach(filteredTransactions) { tx in
                                TransactionRow(transaction: tx)
                                    .contextMenu {
                                        Button {
                                            transactionToEdit = tx
                                        } label: {
                                            Label("Изменить", systemImage: "pencil")
                                        }
                                        Button(role: .destructive) {
                                            withAnimation { modelContext.delete(tx) }
                                        } label: {
                                            Label("Удалить", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                    }
                }
                .padding(16)
            }
            .background(AppTheme.Colors.background)
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $isPresentedAddSheet) {
                TransactionFormSheet(transaction: nil)
            }
            .sheet(item: $transactionToEdit) { tx in
                TransactionFormSheet(transaction: tx)
            }
            .overlay {
                if transactions.isEmpty {
                    ContentUnavailableView(
                        "Пока нет операций",
                        systemImage: "banknote",
                        description: Text("Нажмите на + чтобы записать доход или расход")
                    )
                }
            }
        }
    }
    
    //MARK: - Header
    private var headerView: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Финансы")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                
                Text(transactions.isEmpty ? "Управляйте доходами и расходами" : "\(transactions.count) операций за все время")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
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
    
    //MARK: - Balance Card
    private var balanceSummaryCard: some View {
        VStack(spacing: 14) {
            //Верхняя часть: Баланс
            VStack(alignment: .leading, spacing: 6) {
                Text("ОБЩИЙ БАЛАНС")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(formatCurrency(balance))
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(balance >= 0 ? Color.primary: AppTheme.Colors.coral)
                    
                    Text("₽")
                        .font(.title2.bold())
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Divider()
            
            //Нижняя часть: Доходы и Расходы
            HStack(spacing: 12) {
                //Доходы
                HStack(spacing: 8) {
                    Image(systemName: "arrow.down.left.circle.fill")
                        .font(.title3)
                        .foregroundStyle(AppTheme.Colors.financeAccent)
                    
                    VStack(alignment: .leading, spacing: 2){
                        Text("Доходы")
                            .font(.caption2)
                            .foregroundStyle(AppTheme.Colors.textSecondary)
                        Text("+\(formatCurrency(totalIncome)) ₽")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(AppTheme.Colors.financeAccent)
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                //Расходы
                HStack(spacing: 8) {
                    Image(systemName: "arrow.up.right.circle.fill")
                        .font(.title3)
                        .foregroundStyle(AppTheme.Colors.coral)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Расходы")
                            .font(.caption2)
                            .foregroundStyle(AppTheme.Colors.textSecondary)
                        
                        Text("-\(formatCurrency(totalExpenses)) ₽")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(AppTheme.Colors.coral)
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(16)
        .glassEffect(.regular.tint(AppTheme.Colors.financeAccent.opacity(0.18)), in: RoundedRectangle(cornerRadius: AppTheme.Layout.cardRadius))
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let isInt = value.truncatingRemainder(dividingBy: 1) == 0
        return isInt ? String (format: "%.0f", value) : String(format: "%.2f", value)
    }
}
