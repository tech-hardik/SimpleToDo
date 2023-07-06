//
//  CustomFilteringDataView.swift
//  SimpleTodo
//
//  Created by HARDIK SHARMA on 04/07/23.
//

import SwiftUI

struct CustomFilteringDataView<Content: View>: View {
    var content: (Task) -> Content
    @FetchRequest private var result: FetchedResults<Task>
    init(displayPendingTask: Bool, filterDate: Date, content: @escaping (Task) -> Content) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: filterDate)
        let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: startOfDay)
        
        let predicate = NSPredicate(format: "date >= %@ AND date <= %@ AND isCompleted == %i", (startOfDay as NSDate),(endOfDay! as NSDate),!displayPendingTask)
        
        _result = FetchRequest(entity: Task.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Task.date, ascending: false)],predicate: predicate,animation: .easeInOut(duration: 0.25))
        
        self.content = content
    }
    var body: some View {
        Group{
            if result.isEmpty {
                Text("No Tasks Found")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .listRowSeparator(.hidden)
                
            } else {
                ForEach(result){
                    content($0)
                }
            }
        }
    }
}

struct CustomFilteringDataView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
