//
//  SettingsView.swift
//  DTCProject
//
//  Created by Finn McMillan on 3/8/25.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var appManager: AppManager
    @Environment(\.modelContext) private var context
    var settings: Settings
    var body: some View {
        ZStack {
            Color(.white)
            .ignoresSafeArea()
            VStack{
                HStack{
                    Label("Settings", systemImage: "gear")
                        .font(.system(size: 40))
                        .padding(.leading, 20)
                        .foregroundStyle(.black)
                        .bold()
                        .padding(.top, 10)
                    Spacer()
                }
                .padding(.bottom, 30)
                HStack{
                    Text("'Yes' Sound Effect:")
                        .font(.title2)
                        .padding(.leading, 20)
                        .foregroundStyle(.black)
                        .bold()
                        .padding(.leading, 20)
                    Spacer()
                    Menu {
                        Button("Female Voice"){
                            appManager.yesSound = "yes-female"
                        }
                        Button("Male Voice"){
                            appManager.yesSound = "yes-male"
                        }
                        Button("Ding"){
                            appManager.yesSound = "ding"
                        }
                           }
                    label: {
                        Label(appManager.yesSound == "yes-female" ? "Female Voice" : appManager.yesSound == "yes-male" ? "Male Voice" : "Ding", systemImage: "chevron.down")
                            .foregroundStyle(.black)
                        
                    }
                    .padding(.trailing, appManager.yesSound == "ding" ? 80 : 40)
                }
                .padding(.bottom, 20)
                HStack{
                    Text("'No' Sound Effect:")
                        .font(.title2)
                        .padding(.leading, 20)
                        .foregroundStyle(.black)
                        .bold()
                        .padding(.leading, 20)
                    Spacer()
                    Menu {
                        Button("Female Voice"){
                            appManager.noSound = "no-female"
                        }
                        Button("Male Voice"){
                            appManager.noSound = "no-male"
                        }
                           }
                    label: {
                        Label(appManager.noSound == "no-female" ? "Female Voice" : appManager.noSound == "no-male" ? "Male Voice" : "Tone", systemImage: "chevron.down")
                            .foregroundStyle(.black)
                        
                    }
                    .padding(.trailing, appManager.noSound == "tone" ? 80 : 40)
                }
                .padding(.bottom, 50)
                HStack{
                    Text("'Yes' Icon:")
                        .font(.title2)
                        .padding(.leading, 20)
                        .bold()
                        .foregroundStyle(.black)

                }
                HStack{
                    Button {
                        appManager.yesIcon = "yes-face"
                    } label: {
                        Image("yes-face")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .padding()
                            .overlay {
                                if appManager.yesIcon == "yes-face"{
                                    Rectangle()
                                        .stroke(lineWidth: 4.0)
                                        .foregroundStyle(.green)
                                }
                            }
                    }
                    Button {
                        appManager.yesIcon = "circle"
                        print(appManager.yesIcon)
                    } label: {
                        Image("circle")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .padding()
                            .overlay {
                                if appManager.yesIcon == "circle"{
                                    Rectangle()
                                        .stroke(lineWidth: 4.0)
                                        .foregroundStyle(.green)
                                }
                            }
                    }
                    Button {
                        appManager.yesIcon = "checkmark"
                    } label: {
                          Image("checkmark")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .padding()
                        .overlay {
                            if appManager.yesIcon == "checkmark"{
                                Rectangle()
                                    .stroke(lineWidth: 4.0)
                                    .foregroundStyle(.green)
                            }
                        }
                    }
                }
                .padding(.bottom, 20)
                HStack{
                    Text("'No' Icon:")
                        .padding(.leading, 20)
                        .font(.title2)
                        .foregroundStyle(.black)
                        .bold()
                }
                HStack{
                    Button {
                        appManager.noIcon = "no-face"
                    } label: {
                        Image("no-face")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .padding()
                            .overlay {
                                if appManager.noIcon == "no-face"{
                                    Rectangle()
                                        .stroke(lineWidth: 4.0)
                                        .foregroundStyle(.green)
                                }
                            }
                    }
                    .padding(.trailing, 30)
                    Button {
                        appManager.noIcon = "xmark"
                    } label: {
                        Image("xmark")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .padding()
                            .overlay {
                                if appManager.noIcon == "xmark"{
                                    Rectangle()
                                        .stroke(lineWidth: 4.0)
                                        .foregroundStyle(.green)
                                }
                            }
                    }
                }
                Spacer()
            }
        }
        .onDisappear {
            updateSettings(settings)
        }
    }
    func updateSettings(_ settings: Settings){
        do {
            settings.yesIcon = appManager.yesIcon
            settings.noIcon = appManager.noIcon
            settings.yesSound = appManager.yesSound
            settings.noSound = appManager.noSound
            try context.save()
        }
        catch{
            return
        }
    }
}

#Preview {
    SettingsView(appManager: AppManager(yesSound: "", noSound: "", yesIcon: "", noIcon: ""), settings: Settings(yesSound: "", noSound: "", yesIcon: "", noIcon: ""))
}
