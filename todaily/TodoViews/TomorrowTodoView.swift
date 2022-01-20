//
//  TomorrowTodoView.swift
//  todaily
//
//  Created by 이예민 on 2022/01/19.
//

import SwiftUI

struct TomorrowTodoView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var todoContent: String = ""
    @State private var showAddTodoModal: Bool = false
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Todo.content, ascending: true)], animation: .default)
    private var todos: FetchedResults<Todo>
    
    var body: some View {
        ZStack {
            Color("TodoBeige")
                .edgesIgnoringSafeArea(.all)
            VStack {
                HStack {
                    Button(action: addTodo) {
                        Label("", systemImage: "line.3.horizontal")
                            .font(.system(size: 25))
                            .foregroundColor(Color("TodoRed"))
                            .padding()
                    }
                    Spacer()
                    VStack {
                        Text("내일")
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .foregroundColor(Color("TodoBlue"))
                        Text(Formatter.weekDay.string(from: Date()))
                            .font(.system(size: 13))
                            .foregroundColor(Color("TodoBlue"))
                    }
                    Spacer()
                    Button(action: {showAddTodoModal = true}) {
                        Label("", systemImage: "plus")
                            .font(.system(size: 25))
                            .foregroundColor(Color("TodoRed"))
                            .padding()
                    }
                }.padding()
                Spacer()
            }
            .sheet(isPresented: $showAddTodoModal) {
                AddTodoModalView()
            }
        }
    }
    
    private func addTodo() {
        withAnimation {
            let newTodo = Todo(context: viewContext)
            newTodo.content = todoContent
            PersistenceController.shared.saveContext()
            todoContent = ""
        }
    }
    
    private func deleteTodo(offsets: IndexSet) {
        withAnimation {
            offsets.map { todos[$0] }.forEach(viewContext.delete)
            PersistenceController.shared.saveContext()
        }
    }
}

struct TomorrowTodoView_Previews: PreviewProvider {
    static var previews: some View {
        TomorrowTodoView()
    }
}
