//
//  SubscriptionCard.swift
//  Cadence
//
//  Created by Arseny Solyanov on 11/5/26.
//
import SwiftUI

struct SubscriptionCard: View {
    let subscriprion: Subscription
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(subscriprion.tintColor.opacity(0.18))
                    .frame(width: 48, height: 48)
                
                Image(systemName: subscriprion.iconName)
                    .font(.title3.bold())
                    .foregroundStyle(subscriprion.tintColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(subscriprion.name)
                    .font(.headline)
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.caption2)
                    Text(paymentDueText)
                        .font(.caption)
                }
                .foregroundStyle(isDueSoon ? AppTheme.Colors.coral : AppTheme.Colors.textSecondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(formattedPrice)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                
                Text(subscriprion.billingCycle.rawValue.lowercased())
                    .font(.caption2)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
        }
        .padding(14)
        .glassEffect(.regular.tint(subscriprion.tintColor.opacity(0.25)), in: RoundedRectangle(cornerRadius: AppTheme.Layout.cardRadius))
    }
    
    //MARK: - Helpers
    private var formattedPrice: String {
        let isInteger = subscriprion.price.truncatingRemainder(dividingBy: 1) == 0
        let formatted = isInteger ? String(format: "%.0f", subscriprion.price) : String(format: "%.2f", subscriprion.price)
        return "\(formatted) \(subscriprion.currencySymbol)"
    }
    
    private var isDueSoon: Bool {
        subscriprion.daysUntilNextPayment <= 3
    }
    
    private var paymentDueText: String {
        let days = subscriprion.daysUntilNextPayment
        if days == 0 {
            return "Сегодня"
        } else if days == 1{
            return "Завтра"
        } else if days < 5 {
            return "Через \(days) дня"
        } else {
            return "\(subscriprion.nextPaymentDate.formatted(.dateTime.day().month(.abbreviated)))"
        }
    }
}
