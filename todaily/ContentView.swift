//
//  ContentView.swift
//  todaily
//
//  Created by 이예민 on 2022/01/17.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            Color("TodoBeige")
                .edgesIgnoringSafeArea(.all)
            TodayTodoView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
        }
    }
}
