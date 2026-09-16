//
//  PlaceholderView.swift
//  Cadence
//
//  Created by Arseny Solyanov on 9/16/26.
//

import SwiftUI

struct PlaceholderView: View {
    let title: String
    let icon: String
    let tint: Color
    
    var body: some View {
        NavigationStack{
            ContentUnavailableView("\(title), скоро", systemImage: icon, description: Text("Этот раздел еще в разработке")
            )
            .foregroundStyle(tint)
            .navigationTitle(title)
        }
    }
}
