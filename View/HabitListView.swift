//
//  HabitListView.swift
//  HabitTracker
//
//  Created by Roman Khancha on 22.10.2024.
//

import SwiftUI

struct HabitListView: View {
    
    @Environment(\.modelContext) private var context
    
    @StateObject var viewModel = HabitViewModel()
    
    @State private var showCreateView = false
    
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.habits) { habit in
                    NavigationLink(destination: HabitDetailView(habit: habit, viewModel: viewModel)) {
                        HStack {
                            Button(action: {
                                viewModel.updateProgress(for: habit)
                            }) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(habit.isUpdatedToday ? .green : .primary)
                            }
                            .buttonStyle(.bordered)
                            
                            VStack(alignment: .leading) {
                                Text(habit.name)
                                    .font(.headline)
                                Text("Frequency: \(habit.frequency.displayName)")
                                    .font(.subheadline)
                                Text("Progress: \(habit.progress)")
                                    .font(.body)
                            }
                        }
                    }
                }
                .onDelete(perform: deleteHabit)
            }
            .navigationTitle("My habits")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showCreateView.toggle()
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showCreateView) {
                HabitCreateView(viewModel: viewModel)
            }
            .onAppear {
                viewModel.setContext(context)
                viewModel.fetchHabits()
            }
        }
    }
    
    func deleteHabit(at offsets: IndexSet) {
        for index in offsets {
            viewModel.deleteHabit(at: index)
        }
    }
}
