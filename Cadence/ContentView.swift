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
                SubscriptionListView()
            }
            
            Tab("Финансы", systemImage: "chart.line.uptrend.xyaxis"){
                FinanceView()
            }
            
            Tab("Дашборд", systemImage: "square.grid.2x2.fill"){
                DashboardView()
            }
        }
    }
}

