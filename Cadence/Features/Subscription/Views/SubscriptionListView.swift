//
//  SubscriptionListView.swift
//  Cadence
//
//  Created by Arseny Solyanov on 11/7/26.
//

import SwiftUI
import SwiftData

struct SubscriptionListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Subscription.firstPaymentDate, order: .forward) private var subscriptions: [Subscription]
    
    @State private var isPresentedAddSheet: Bool = false
    @State private var subscriptionToEdit: Subscription?
    
    //Суммарный расход в месяц
    private var totalMonthlyCost: Double {
        subscriptions.reduce(0) { $0 + $1.monthlyEquivalentCost }
    }
    
    // Ближайшая подписка к оплате
    private var upcomingSubscription: Subscription? {
        subscriptions.min(by: {$0.daysUntilNextPayment < $1.daysUntilNextPayment})
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // MARK: - Шапка экрана
                    headerView
                    
                    if !subscriptions.isEmpty {
                        //MARK: - Баннер сводки расходов
                        monthlySpendBanner
                        
                        //MARK: - Список подписок
                        LazyVStack(spacing: 12) {
                            ForEach(subscriptions) { sub in
                                SubscriptionCard(subscriprion: sub)
                                    .contextMenu{
                                        Button {
                                            subscriptionToEdit = sub
                                        } label: {
                                            Label("Изменить", systemImage: "pencil")
                                        }
                                        Button(role: .destructive) {
                                            withAnimation { modelContext.delete(sub) }
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
                SubscriptionFormSheet(subsriprion: nil)
            }
            .sheet(item: $subscriptionToEdit) { sub in
                SubscriptionFormSheet(subsriprion: sub)
            }
            .overlay {
                if subscriptions.isEmpty {
                    ContentUnavailableView("Пока нет подписок", systemImage: "creditcard", description: Text("Нажмите на +, чтобы добавить первую подписку"))
                }
            }
        }
    }
    
    //MARK: - Header
    private var headerView: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Подписка")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                
                Text(subscriptions.isEmpty ? "Контролируйте регулярные платежи" : "\(subscriptions.count) активных подписок")
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
    
    //MARK: - Spend Banner
    private var monthlySpendBanner: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("В МЕСЯЦ")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                
                Spacer()
                
                if let upcoming = upcomingSubscription {
                    HStack(spacing: 4) {
                        Image(systemName: "bell.fill")
                            .font(.caption2)
                        Text("Ближайшая: \(upcoming.name)")
                            .font(.caption2.weight(.medium))
                    }
                    .foregroundStyle(AppTheme.Colors.subAccent)
                }
            }
            
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(String(format: "%.0f", totalMonthlyCost))
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                
                Text("₽")
                    .font(.title2.bold())
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular.tint(AppTheme.Colors.subAccent.opacity(0.2)), in: RoundedRectangle(cornerRadius: AppTheme.Layout.cardRadius))
    }
}
