//
//  WeekRowView.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 14.01.23.
//

import SwiftUI
import SwiftDevRant

struct WeekRowView: View {
    let week: Weekly
    
    var body: some View {
        HStack(spacing: 8) {
            ZStack {
                Text("XXX")
                    .opacity(0)
                    .accessibilityHidden(true)
                
                Text("\(week.week)")
                    .font(baseSize: 15, weightDelta: 0)
                    .foregroundColor(.primaryForeground)
            }
            .padding(.horizontal, 2)
            .padding(.vertical, 8)
            .background {
                Circle()
                    .foregroundColor(.secondaryBackground)
            }
            
            VStack(spacing: 2) {
                Text(week.topic)
                    .font(baseSize: 16, weightDelta: 0)
                    .multilineTextAlignment(.leading)
                    .fillHorizontally(.leading)
                    .foregroundColor(.primaryForeground)
                
                HStack {
                    Text(AbsoluteDateFormatter.shared.string(fromDevRantUS: week.formattedDate))
                        .font(baseSize: 14, weightDelta: 0)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.secondaryForeground)
                    
                    Spacer()
                    
                    HStack(spacing: 2) {
                        Image(systemName: "bubble.right.fill")
                            .font(baseSize: 12)
                        
                        Text("\(week.numberOfRants)")
                            .font(baseSize: 13)
                    }
                    .foregroundColor(.secondaryForeground)
                }
            }
        }
        .background(Color.primaryBackground)
    }
}

struct WeekRowView_Previews: PreviewProvider {
    static var previews: some View {
        WeekRowView(
            week: .init(
                week: 123,
                topic: "Reasons to hate JS?",
                formattedDate: "12/31/22",
                numberOfRants: 13
            )
        )
        .padding()
    }
}
