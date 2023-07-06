//
//  SimpleTodoApp.swift
//  SimpleTodo
//
//  Created by HARDIK SHARMA on 04/07/23.
//

import SwiftUI

@main
struct SimpleTodoApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
