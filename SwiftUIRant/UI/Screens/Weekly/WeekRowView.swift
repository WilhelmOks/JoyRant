//
//  WeekRowView.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 14.01.23.
//

import SwiftUI
import SwiftRant

struct WeekRowView: View {
    let week: WeeklyList.Week
    
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
                Text(week.prompt)
                    .font(baseSize: 16, weightDelta: 0)
                    .multilineTextAlignment(.leading)
                    .fillHorizontally(.leading)
                    .foregroundColor(.primaryForeground)
                
                HStack {
                    Text(AbsoluteDateFormatter.shared.string(fromDevRantUS: week.date))
                        .font(baseSize: 14, weightDelta: 0)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.secondaryForeground)
                    
                    Spacer()
                    
                    HStack(spacing: 2) {
                        Image(systemName: "bubble.right.fill")
                            .font(baseSize: 12)
                        
                        Text("\(week.rantCount)")
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
                prompt: "Reasons to hate JS?",
                date: "12/31/22",
                rantCount: 13
            )
        )
        .padding()
    }
}
