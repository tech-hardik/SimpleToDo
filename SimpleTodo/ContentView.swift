//
//  ContentView.swift
//  SimpleTodo
//
//  Created by HARDIK SHARMA on 04/07/23.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        NavigationStack {
            Home()
                .navigationTitle("To-Do")
        }
        
    }
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
}
