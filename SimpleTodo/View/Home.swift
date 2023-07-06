//
//  Home.swift
//  SimpleTodo
//
//  Created by HARDIK SHARMA on 04/07/23.
//

import SwiftUI

struct Home: View {
    /// View Properties
    @Environment(\.self) private var env
    @State private var filterDate: Date = .init()
    @State private var showPendingTasks: Bool = true
    @State private var showCompletedTasks: Bool = true
    var body: some View {
        List{
            DatePicker(selection: $filterDate, displayedComponents: [.date]){
            }
            .labelsHidden()
            .datePickerStyle(.graphical)
            
            DisclosureGroup(isExpanded: $showPendingTasks){
              /// Custom Core Data Filter View, which will dispaly only those tasks which are pending on this day
                CustomFilteringDataView(displayPendingTask: true, filterDate: filterDate){
                    TaskRow(task: $0, isPendingTask: true)
                }
            } label: {
                Text("Pending Tasks")
                    .font(.caption)
                    .foregroundColor(.red)
            }
            
            DisclosureGroup(isExpanded: $showCompletedTasks){
                /// Custom Core Data Filter View, which will dispaly only those tasks which are completed  on this day
                CustomFilteringDataView(displayPendingTask: false, filterDate: filterDate){
                    TaskRow(task: $0, isPendingTask: false)
                }
            } label: {
                Text("Completed Tasks")
                    .font(.caption)
                    .foregroundColor(.green)
            }
            
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar){
                Button{
                    ///Simply Opening Pending Task View
                    ///Then Adding An Empty Task
                    do {
                        let task = Task(context: env.managedObjectContext)
                        task.id = .init()
                        task.date = filterDate
                        task.title = ""
                        task.isCompleted = false
                        
                        try env.managedObjectContext.save()
                        showPendingTasks = true
                    } catch {
                        print(error.localizedDescription)
                    }
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                         Text("New Task")
                    }
                    .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView  ()
    }
}

struct TaskRow: View {
    @ObservedObject var task: Task
    var isPendingTask: Bool
    ///View Properties
    @Environment(\.self) private var env
    @FocusState private var showKeyboard: Bool
    var body: some View {
        HStack(spacing:12){
            Button{
                task.isCompleted.toggle()
                save()
            } label: {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title)
                    .foregroundColor(.blue)
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 4){
                TextField("Task Title", text: .init(get: {return task.title ?? "" }, set: { value in task.title = value }))
                    .focused($showKeyboard)
                    .onSubmit {
                        removeEmptyTask()
                        save()
                    }
                    .foregroundColor(isPendingTask ? .primary :.gray )
                    .strikethrough(!isPendingTask, pattern: .dash, color: .primary)
                ///Custom Date Picker
                Text((task.date ?? .init()).formatted(date: .omitted, time: .shortened))
                    .font(.callout)
                    .foregroundColor(.gray)
                    .overlay{
                        DatePicker(selection: .init(get: { return task.date ?? .init()}, set: { value in task.date = value ///Saving Date Whenever it's updated
                            save()
                        }), displayedComponents: [.hourAndMinute]) {
                        }
                        .labelsHidden()
                        .blendMode(.destinationOver)
                    }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .onAppear(){
            if (task.title ?? "").isEmpty{
                showKeyboard = true
            }
        }
        /// Verifying  Content when user leaves the App
        .onChange(of: env.scenePhase) { newValue in
            if newValue != .active {
                ///Checking if it's empty
                removeEmptyTask()
                save()
            }
        }
        
        ///Adding Swipe To Delete
        .swipeActions(edge:.trailing, allowsFullSwipe: true){
            Button(role: .destructive){
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                    env.managedObjectContext.delete(task)
                    save()
                }
            } label: {
                Image(systemName: "trash.fill")
            }
        }
    }
    
    /// Context Saving Method
    func save(){
        do {
            try env.managedObjectContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /// Removing Empty Tasks
    func removeEmptyTask() {
        if (task.title ?? "").isEmpty {
            ///Removing Empty Task
            env.managedObjectContext.delete(task)
        }
    }
}
    

