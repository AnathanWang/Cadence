//
//  TransactionRow.swift
//  Cadence
//
//  Created by Arseny Solyanov on 11/11/26.
//

import SwiftUI

struct TransactionRow: View {
    let transaction: Transaction
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(transaction.categoryColor.opacity(0.18))
                    .frame(width: 44, height: 44)
                
                Image(systemName: transaction.category.iconName)
                    .font(.subheadline.bold())
                    .foregroundStyle(transaction.categoryColor)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(transaction.title)
                    .font(.body.weight(.semibold))
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    Text(transaction.category.rawValue)
                        .font(.caption2)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                    
                    Text("•")
                        .font(.caption2)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                    
                    Text(transaction.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption2)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                }
            }
            
            Spacer()
            
            // Сумма
            Text(transaction.formattedAmount)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(transaction.type == .income ? AppTheme.Colors.financeAccent : Color.primary
                )
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 16))
    }
}
