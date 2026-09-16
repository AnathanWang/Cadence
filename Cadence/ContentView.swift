//
//  ContentView.swift
//  Cadence
//
//  Created by Arseny Solyanov on 9/15/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Привычки", systemImage: "star.fill") {
                HabitListView()
            }
            
            Tab("Подписки", systemImage: "creditcard.fill"){
                PlaceholderView(
                    title: "Подписки",
                    icon: "creditcard.fill",
                    tint: AppTheme.Colors.subAccent
                )
            }
            
            Tab("Финансы", systemImage: "chart.line.uptrend.xyaxis"){
                PlaceholderView(
                    title: "Финансы",
                    icon: "chart.line.uptrend.xyaxis",
                    tint: AppTheme.Colors.financeAccent
                )
            }
            
            Tab("Дашборд", systemImage: "square.grid.2x2.fill"){
                PlaceholderView(
                    title: "Дашборд",
                    icon: "square.grid.2x2.fill",
                    tint: AppTheme.Colors.indigo
                )
            }
        }
    }
}

