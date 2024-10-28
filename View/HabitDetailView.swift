//
//  HabitDetailView.swift
//  HabitTracker
//
//  Created by Roman Khancha on 25.10.2024.
//

import SwiftUI

struct HabitDetailView: View {
    @State private var frequency: Frequency
    @State private var reminderTime: Date
    @State private var isModified = false
    
    var habit: Habit
    @ObservedObject var viewModel: HabitViewModel
    
    init(habit: Habit, viewModel: HabitViewModel) {
        self.habit = habit
        self.viewModel = viewModel
        self._frequency = State(initialValue: habit.frequency)
        self._reminderTime = State(initialValue: habit.reminderTime ?? Date())
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(habit.name)
                .font(.title)
                .padding()
            
            HStack {
                Text("Days in a row:")
                Text("\(habit.progress)")
                    .bold()
            }
            .padding()
            
            HStack {
                Text("Reminder:")
                DatePicker("", selection: $reminderTime, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .onChange(of: reminderTime, {
                        isModified = true
                    })
            }
            .padding()
            
            HStack {
                Text("How offen:")
                Picker("", selection: $frequency) {
                    ForEach(Frequency.allCases, id: \.self) { frequency in
                        Text(frequency.displayName)
                    }
                }
                .pickerStyle(.menu)
                .onChange(of: frequency, {
                    isModified = true
                })
            }
            .padding()
            
            Button(action: {
                if isModified {
                    habit.reminderTime = reminderTime
                    habit.frequency = frequency
                    
                    viewModel.saveHabit(habit)
                    
                    if let reminderTime = habit.reminderTime {
                        viewModel.scheduleNotification(for: habit, at: reminderTime)
                    }
                    
                    isModified = false
                }
            }) {
                Text("Change")
                    .foregroundColor(isModified ? .red : .gray)
                    .disabled(!isModified)
            }
            .padding()
            
            CalendarView(habit: habit)
                .padding()
            
            Spacer()
        }
        .padding()
        .navigationTitle("Habit Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
