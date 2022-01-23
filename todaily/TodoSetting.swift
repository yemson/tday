//
//  AddTodoModalView.swift
//  todaily
//
//  Created by 이예민 on 2022/01/18.
//

import SwiftUI

struct TodoSetting: View {
    
    @AppStorage("weatherRegion") var weatherRegion: String = ""
    var todoView: TodoView = TodoView()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("날씨 지역 설정"), content: {
                    Menu("지역 선택") {
                        Button(action: {
                            weatherRegion = "Seoul"
                            todoView.loadData()
                        }) {
                            Text("서울")
                        }
                        Button(action: {
                            weatherRegion = "Busan"
                            todoView.loadData()
                        }) {
                            Text("부산")
                        }
                    }
                    HStack {
                        Text("현재 선택된 지역")
                        Spacer()
                        Text("부산")
                            .foregroundColor(Color.secondary)
                    }
                })
                Section(header: Text("테마 설정"), content: {
                    Text("만드는 중...")
                        .foregroundColor(Color.secondary)
                })
            }
            .navigationTitle("설정")
        }
    }
}
