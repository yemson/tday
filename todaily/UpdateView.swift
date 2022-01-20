//
//  UpdateView.swift
//  todaily
//
//  Created by 이예민 on 2022/01/17.
//

import SwiftUI

struct UpdateView: View {
    @StateObject var todo: Todo
    
    @State private var todoContent: String = ""
    
    var body: some View {
        VStack {
            HStack {
                TextField("할 일 수정", text: $todoContent)
                    .textFieldStyle(.roundedBorder)
                Button(action: updateTodo) {
                    Label("", systemImage: "arrowshape.turn.up.left")
                }
            }.padding()
            Text(todo.content ?? "")
            Spacer()
        }
    }
    
    private func updateTodo() {
        withAnimation {
            todo.content = todoContent
            PersistenceController.shared.saveContext()
        }
    }
}
