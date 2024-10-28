//
//  CalendarView.swift
//  HabitTracker
//
//  Created by Roman Khancha on 25.10.2024.
//

import SwiftUI

struct CalendarView: View {
    
    @ObservedObject var viewModel = HabitViewModel()
    
    @State private var currentDate = Date()
    
    var habit: Habit
    
    var body: some View {
        VStack {
            Text("Execution calendar")
                .font(.headline)
            
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                }
                
                Text(currentDate.formatted(.dateTime.year().month()))
                    .font(.headline)
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding(.vertical)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                ForEach(viewModel.getMonthDays(for: currentDate), id: \.self) { date in
                    VStack {
                        if habit.dailyCheck[date] == true {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 30, height: 30)
                                .overlay(Text("\(Calendar.current.component(.day, from: date))")
                                    .foregroundColor(.white))
                        } else {
                            Circle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 30, height: 30)
                                .overlay(Text("\(Calendar.current.component(.day, from: date))")
                                    .foregroundColor(.black))
                        }
                    }
                }
            }
        }
    }
    
    private func previousMonth() {
        if let newDate = Calendar.current.date(byAdding: .month, value: -1, to: currentDate) {
            currentDate = newDate
        }
    }
    
    private func nextMonth() {
        if let newDate = Calendar.current.date(byAdding: .month, value: 1, to: currentDate) {
            currentDate = newDate
        }
    }
}
