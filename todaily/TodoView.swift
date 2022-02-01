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

struct TodoView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.scenePhase) var scenePhase
    @AppStorage("weatherRegion") var weatherRegion: String = ""
    @AppStorage("weatherIcon") var weatherIcon: String = ""
    @State private var todoContent: String = ""
    @State private var showAddTodoModal: Bool = false
    @State private var showingAlert: Bool = false
    @State var showWeather: String = ""
    @State private var todoTime = Date()
    @State private var timeCheck: Bool = false
    @State private var showSelectTime: Bool = false
    @State private var timeNow = Date()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @FocusState private var focus: Bool
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Todo.time, ascending: true)], animation: .default)
    private var todos: FetchedResults<Todo>
    
    var body: some View {
        ZStack {
            Color("TodoBeige")
                .edgesIgnoringSafeArea(.all)
            VStack {
                HStack {
                    Button(action: {showAddTodoModal = true}) {
                        Label("", systemImage: "gearshape")
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
                    Button(action: {focus = !focus}) {
                        Label("", systemImage: "plus")
                            .font(.system(size: 25))
                            .foregroundColor(Color("TodoRed"))
                            .padding()
                    }
                }.padding(.horizontal)
                VStack(spacing: 20) {
                    HStack {
                        TextField("", text: $todoContent)
                            .focused($focus)
                            .onSubmit({
                                print(timeCheck)
                                if (timeCheck == true) {
                                    createNotification(notiContent: todoContent, notiTime: todoTime)
                                }
                                addTodo()
                                focus = true
                            })
                            .submitLabel(.done)
                            .placeholder("이 곳에 할 일을 적어주세요", when: todoContent.isEmpty)
                        Button(action: {self.showSelectTime = !self.showSelectTime}) {
                            Label("", systemImage: self.showSelectTime ? "calendar.badge.minus" : "calendar.badge.plus")
                                .font(.system(size: 25))
                                .foregroundColor(Color("TodoBlue"))
                        }
                    }
                    if showSelectTime {
                        VStack(spacing: 15) {
                            DatePicker("날짜 선택", selection: $todoTime)
                                .foregroundColor(Color("TodoBlue"))
                                .accentColor(Color("TodoBlue"))
                                .environment(\.locale, Locale.init(identifier: "ko"))
                            Toggle("알림 받기", isOn: $timeCheck)
                                .foregroundColor(Color("TodoBlue"))
                                .tint(Color("TodoBlue"))
                        }
                    }
                }.padding(.horizontal, 25.0)
                    .padding(.vertical, 10.0)
                Divider()
                    .padding([.leading, .bottom, .trailing])
                List {
                    ForEach(todos) { todo in
                        GeometryReader { geometry in
                            VStack(alignment: .center) {
                                Text(todo.content ?? "")
                                    .font(.system(size: 20))
                                    .fontWeight(todo.star ? .bold : .semibold)
                                    .foregroundColor(todo.star ? Color("TodoRed") : Color("TodoBlue"))
                                    .strikethrough(todo.state ? true : false)
                                    .onTapGesture {
                                        updateTodoState(todo: todo)
                                    }
                                if todo.timeActive {
                                    HStack {
                                        Text(Formatter.hour.string(from: todo.time ?? Date()))
                                            .foregroundColor(todo.notiActive ? Color("TodoRed") : Color.secondary)
                                            .strikethrough(todo.time! < timeNow ? true : false)
                                    }
                                }
                            }.frame(width: geometry.size.width)
                            
                        }.swipeActions(edge: .leading, allowsFullSwipe: false) {
                            Button(action: {updateTodoStar(todo: todo)}) {
                                Label("", systemImage: todo.star ? "star.slash" : "star")
                            }
                            .tint(Color("TodoBlue"))
                        }.swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(action: {deleteTodo(todo: todo)}) {
                                Label("", systemImage: "trash")
                            }
                            .tint(Color("TodoRed"))
                        }
                    }
                    .listRowBackground(Color("TodoBeige"))
                    .listRowSeparator(.hidden)
                }
                .environment(\.defaultMinListRowHeight, 65)
                .environment(\.locale, Locale(identifier: "ko"))
                .listStyle(.plain)
                Spacer()
                HStack {
                    Label("", systemImage: weatherIcon)
                        .font(.system(size: 50))
                        .foregroundColor(Color("TodoBlue"))
                        .padding()
                }
            }
            .sheet(isPresented: $showAddTodoModal) {
                TodoSetting()
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("빈 칸은 등록할 수 없습니다!"), message: nil,
                      dismissButton: .default(Text("확인")))
            }.onAppear(perform: loadData)
                .onAppear(perform : UIApplication.shared.hideKeyboard)
                .onChange(of: scenePhase) { newPhase in
                    if newPhase == .active {
                        loadData()
                        todoTime = Date()
                    }
                }
                .onReceive(timer) { _ in
                    self.timeNow = Date()
                    self.todoTime = Date()
                }
        }
        .ignoresSafeArea(.keyboard)
    }
    
    private func addTodo() {
        if (todoContent == "") {
            showingAlert.toggle()
        } else if (todoContent != "") {
            let newTodo = Todo(context: viewContext)
            newTodo.content = todoContent
            newTodo.state = false
            newTodo.time = todoTime
            newTodo.timeActive = showSelectTime
            newTodo.star = false
            newTodo.notiActive = timeCheck
            PersistenceController.shared.saveContext()
            todoContent = ""
            print(newTodo)
        }
    }
    
    private func deleteTodo(todo: Todo) {
        viewContext.delete(todo)
        PersistenceController.shared.saveContext()
    }
    
    private func updateTodoState(todo: Todo) {
        todo.state = !todo.state
        PersistenceController.shared.saveContext()
    }
    
    private func updateTodoStar(todo: Todo) {
        todo.star = !todo.star
        PersistenceController.shared.saveContext()
    }
    
    func loadData() {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(weatherRegion)&appid=\(Storage().weatherAPI)") else {
            fatalError("Invalid URL")
        }
        print(weatherRegion)
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                return
            }
            
            let result = try? JSONDecoder().decode(WeatherResponse.self, from: data)
            if let result = result {
                result.weather.forEach {
                    print($0.description)
                    if ($0.description == "clear sky") {
                        weatherIcon = "sun.max"
                    } else if ($0.description == "few clouds") {
                        weatherIcon = "cloud.sun"
                    } else if ($0.description == "scattered clouds" || $0.description == "broken clouds" || $0.description == "overcast clouds") {
                        weatherIcon = "cloud"
                    } else if ($0.description == "shower rain") {
                        weatherIcon = "cloud.drizzle"
                    } else if ($0.description == "rain") {
                        weatherIcon = "cloud.rain"
                    } else if ($0.description == "thunderstorm") {
                        weatherIcon = "cloud.bolt"
                    } else if ($0.description == "snow") {
                        weatherIcon = "cloud.snow"
                    } else if ($0.description == "mist") {
                        weatherIcon = "cloud.fog"
                    }
                }
            }
            print(weatherIcon)
        }.resume()
    }
    
    func createNotification(notiContent: String, notiTime: Date) {
        let content = UNMutableNotificationContent()
        content.title = "TDAY"
        content.subtitle = notiContent
        content.sound = .default
        
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: notiTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: notiContent, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}

extension View {
    func placeholder(
        _ text: String,
        when shouldShow: Bool,
        alignment: Alignment = .leading) -> some View {
            
            placeholder(when: shouldShow, alignment: alignment) { Text(text).foregroundColor(Color("TodoBlue")) }
        }
}
