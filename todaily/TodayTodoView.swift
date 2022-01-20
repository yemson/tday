//
//  TodayTodoView.swift
//  todaily
//
//  Created by 이예민 on 2022/01/19.
//

import SwiftUI
import XCTest

struct TodayTodoView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var todoContent: String = ""
    @State private var showAddTodoModal: Bool = false
    @State private var showingAlert: Bool = false
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Todo.content, ascending: true)], animation: .default)
    private var todos: FetchedResults<Todo>
    
    var body: some View {
        ZStack {
            Color("TodoBeige")
                .edgesIgnoringSafeArea(.all)
            VStack {
                HStack {
                    Button(action: {self.showAddTodoModal = true}) {
                        Label("", systemImage: "line.3.horizontal")
                            .font(.system(size: 25))
                            .foregroundColor(Color("TodoRed"))
                            .padding()
                    }
                    Spacer()
                    VStack {
                        Text("오늘")
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .foregroundColor(Color("TodoBlue"))
                        Text(Formatter.weekDay.string(from: Date()))
                            .font(.system(size: 13))
                            .foregroundColor(Color("TodoBlue"))
                    }
                    Spacer()
                    Button(action: addTodo) {
                        Label("", systemImage: "plus")
                            .font(.system(size: 25))
                            .foregroundColor(Color("TodoRed"))
                            .padding()
                    }
                }.padding()
                TextField("이곳에 할 일을 적어주세요", text: $todoContent)
                    .padding()
                Divider()
                    .padding([.leading, .bottom, .trailing])
                List {
                    ForEach(todos) { todo in
                        GeometryReader { geometry in
                            VStack(alignment: .center) {
                                Spacer()
                                Text(todo.content ?? "")
                                    .font(.system(size: 20))
                                    .fontWeight(.bold)
                                    .foregroundColor(Color("TodoBlue"))
                                    .strikethrough(todo.state >= 1 ? true : false)
                                    .onTapGesture {
                                        if (todo.state >= 1) {
                                            deleteTodo(todo: todo)
                                        } else {
                                            updateTodoState(todo: todo)
                                        }
                                    }
                                Spacer()
                            }.frame(width: geometry.size.width)
                        }
                    }
                    .listRowBackground(Color("TodoBeige"))
                    .listRowSeparator(.hidden)
                    
                }
                .environment(\.locale, Locale(identifier: "ko"))
                .listStyle(.plain)
                Spacer()
            }
            .sheet(isPresented: $showAddTodoModal) {
                AddTodoModalView()
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("빈 칸을 등록할 수 없습니다!"), message: nil,
                      dismissButton: .default(Text("확인")))
            }
        }
    }
    
    private func addTodo() {
        if (todoContent == "") {
            showingAlert.toggle()
        } else if (todoContent != "") {
            let newTodo = Todo(context: viewContext)
            newTodo.content = todoContent
            PersistenceController.shared.saveContext()
            todoContent = ""
        }
    }
    
    private func deleteTodo(todo: Todo) {
        viewContext.delete(todo)
        PersistenceController.shared.saveContext()
    }
    
    private func updateTodoState(todo: Todo) {
        todo.state += 1
        PersistenceController.shared.saveContext()
        print(todo.state)
    }
}

struct TodayTodoView_Previews: PreviewProvider {
    static var previews: some View {
        TodayTodoView()
    }
}
