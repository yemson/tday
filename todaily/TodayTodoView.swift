//
//  TodayTodoView.swift
//  todaily
//
//  Created by 이예민 on 2022/01/19.
//

import SwiftUI
import XCTest

struct Weather: Decodable {
    var main: String
    var description: String
}

struct WeatherResponse: Decodable {
    let weather: [Weather]
}

struct TodayTodoView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var todoContent: String = ""
    @State private var showAddTodoModal: Bool = false
    @State private var showingAlert: Bool = false
    @State private var showWeather: String = ""
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Todo.content, ascending: true)], animation: .default)
    private var todos: FetchedResults<Todo>
    
    var body: some View {
        ZStack {
            Color("TodoBeige")
                .edgesIgnoringSafeArea(.all)
            VStack {
                HStack {
                    Button(action: {showAddTodoModal = true}) {
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
                HStack {
                    Spacer()
                    Label("", systemImage: showWeather)
                        .font(.system(size: 50))
                        .foregroundColor(Color("TodoBlue"))
                        .padding()
                    Spacer()
                }
            }
            .sheet(isPresented: $showAddTodoModal) {
                AddTodoModalView()
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("빈 칸은 등록할 수 없습니다!"), message: nil,
                      dismissButton: .default(Text("확인")))
            }.onAppear(perform: loadData)
                .onAppear (perform : UIApplication.shared.hideKeyboard)
        }
        .ignoresSafeArea(.keyboard)
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
    
    func loadData() {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=Busan&appid=8e71ae892d923505cdcff82dafb4ed43") else {
            fatalError("Invalid URL")
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                return
            }
            
            let result = try? JSONDecoder().decode(WeatherResponse.self, from: data)
            if let result = result {
                print(result)
                result.weather.forEach {
                    print($0.main)
                    print($0.description)
                    switch $0.description {
                    case "clear sky":
                        showWeather = "sun.max"
                        break
                    case "few clouds":
                        showWeather = "cloud.sun"
                        break
                    case "scattered clouds":
                        showWeather = "cloud"
                        break
                    case "broken clouds":
                        showWeather = "cloud"
                        break
                    case "shower rain":
                        showWeather = "cloud.drizzle"
                        break
                    case "rain":
                        showWeather = "cloud.rain"
                        break
                    case "thunderstorm":
                        showWeather = "cloud.bolt"
                        break
                    case "snow":
                        showWeather = "cloud.snow"
                        break
                    case "mist":
                        showWeather = "cloud.fog"
                        break
                    default:
                        break
                    }
                }
            }
        }.resume()
    }
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

struct TodayTodoView_Previews: PreviewProvider {
    static var previews: some View {
        TodayTodoView()
    }
}
